import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../database/user_database_schema.dart';

/// Data Access Object for Synchronization and Reference Dataset Metadata in `riturasa_user.db`.
class SyncMetadataDao {
  final Database db;

  const SyncMetadataDao(this.db);

  /// Get metadata value by key.
  Future<Result<String?>> getMetadata(String key) async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tableSyncMetadata,
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (rows.isEmpty) {
        return const Result.ok(null);
      }
      return Result.ok(rows.first['value'] as String?);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch sync metadata for key $key: $e',
        cause: e,
      ));
    }
  }

  /// Upsert metadata key-value pair.
  Future<Result<void>> setMetadata(String key, String value) async {
    try {
      await db.insert(
        UserDatabaseSchema.tableSyncMetadata,
        {
          'key': key,
          'value': value,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to update sync metadata for key $key: $e',
        cause: e,
      ));
    }
  }

  /// Get all metadata key-value pairs as a map.
  Future<Result<Map<String, String>>> getAllMetadata() async {
    try {
      final rows = await db.query(UserDatabaseSchema.tableSyncMetadata);
      final map = <String, String>{};
      for (final r in rows) {
        map[r['key'] as String] = r['value'] as String;
      }
      return Result.ok(map);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch all sync metadata: $e',
        cause: e,
      ));
    }
  }
}
