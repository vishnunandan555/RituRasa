import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../config/app_config.dart';
import '../../data/local/database/user_database_schema.dart';
import '../errors/failure.dart';
import '../utils/result.dart';

/// Manages connections and lifecycles for both:
/// 1. `nutrition_reference.db`: Bundled read-only nutrition knowledge base (FTS5 search).
/// 2. `riturasa_user.db`: Read-write local user state (profile, cycle, kitchen, intake).
class DatabaseManager {
  static DatabaseManager? _instance;
  static DatabaseManager get instance => _instance ??= DatabaseManager._internal();

  DatabaseManager._internal();

  factory DatabaseManager() => instance;

  Database? _referenceDb;
  Database? _userDb;
  String? _customDatabaseDirectory;

  /// Optional override for unit/integration tests to set a custom database directory.
  @visibleForTesting
  void setCustomDatabaseDirectory(String? dir) {
    _customDatabaseDirectory = dir;
  }

  /// Ensure FFI factory is configured on desktop platforms or during headless unit testing.
  static void ensureFfiInitialized() {
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Directory where SQLite database files are stored.
  Future<String> getDatabaseDirectoryPath() async {
    if (_customDatabaseDirectory != null) {
      final dir = Directory(_customDatabaseDirectory!);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return _customDatabaseDirectory!;
    }

    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      final docDir = await getApplicationSupportDirectory();
      final dbDir = Directory(p.join(docDir.path, 'databases'));
      if (!dbDir.existsSync()) {
        dbDir.createSync(recursive: true);
      }
      return dbDir.path;
    } else {
      return await getDatabasesPath();
    }
  }

  /// Get the active connection to the read-only reference database.
  Future<Result<Database>> getReferenceDatabase() async {
    try {
      if (_referenceDb != null && _referenceDb!.isOpen) {
        return Result.ok(_referenceDb!);
      }

      ensureFfiInitialized();
      final dbDir = await getDatabaseDirectoryPath();
      final dbPath = p.join(dbDir, AppConfig.referenceDbFileName);
      final file = File(dbPath);

      if (!file.existsSync()) {
        // Copy bundled asset to local disk
        try {
          final ByteData data = await rootBundle.load(AppConfig.referenceDbAssetName);
          final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await file.writeAsBytes(bytes, flush: true);
        } catch (e) {
          return Result.err(DatabaseFailure(
            message: 'Failed to extract bundled reference database asset: $e',
            cause: e,
          ));
        }
      }

      _referenceDb = await openDatabase(
        dbPath,
        readOnly: true,
      );

      return Result.ok(_referenceDb!);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Could not open reference database: $e',
        cause: e,
      ));
    }
  }

  /// Direct injection for testing with an already-opened database.
  @visibleForTesting
  void setReferenceDatabaseForTesting(Database db) {
    _referenceDb = db;
  }

  /// Direct injection for testing with an already-opened user database.
  @visibleForTesting
  void setUserDatabaseForTesting(Database db) {
    _userDb = db;
  }

  /// Get the active connection to the read-write user database.
  Future<Result<Database>> getUserDatabase() async {
    try {
      if (_userDb != null && _userDb!.isOpen) {
        return Result.ok(_userDb!);
      }

      ensureFfiInitialized();
      final dbDir = await getDatabaseDirectoryPath();
      final dbPath = p.join(dbDir, AppConfig.userDbFileName);

      _userDb = await openDatabase(
        dbPath,
        version: UserDatabaseSchema.currentVersion,
        onCreate: UserDatabaseSchema.onCreate,
        onUpgrade: UserDatabaseSchema.onUpgrade,
        onOpen: UserDatabaseSchema.onOpen,
      );

      return Result.ok(_userDb!);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Could not open user database: $e',
        cause: e,
      ));
    }
  }

  /// Close all active database connections.
  Future<void> closeAll() async {
    if (_referenceDb != null && _referenceDb!.isOpen) {
      await _referenceDb!.close();
      _referenceDb = null;
    }
    if (_userDb != null && _userDb!.isOpen) {
      await _userDb!.close();
      _userDb = null;
    }
  }
}
