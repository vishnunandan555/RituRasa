import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../database/user_database_schema.dart';

/// Data Access Object for User Profile and Preferences in `riturasa_user.db`.
class ProfileDao {
  final Database db;

  const ProfileDao(this.db);

  /// Fetch user profile. Returns null if profile is not yet created.
  Future<Result<Map<String, dynamic>?>> getProfile() async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tableProfile,
        limit: 1,
      );
      if (rows.isEmpty) {
        return const Result.ok(null);
      }
      return Result.ok(rows.first);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch user profile: $e',
        cause: e,
      ));
    }
  }

  /// Create or update user profile.
  Future<Result<void>> upsertProfile(Map<String, dynamic> profileData) async {
    try {
      await db.insert(
        UserDatabaseSchema.tableProfile,
        profileData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to save user profile: $e',
        cause: e,
      ));
    }
  }

  /// Fetch dietary preferences and restrictions for a user.
  Future<Result<Map<String, dynamic>?>> getPreferences(String userId) async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tablePreferences,
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (rows.isEmpty) {
        return const Result.ok(null);
      }
      return Result.ok(rows.first);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch user preferences: $e',
        cause: e,
      ));
    }
  }

  /// Create or update preferences.
  Future<Result<void>> upsertPreferences(Map<String, dynamic> preferencesData) async {
    try {
      await db.insert(
        UserDatabaseSchema.tablePreferences,
        preferencesData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to save user preferences: $e',
        cause: e,
      ));
    }
  }
}
