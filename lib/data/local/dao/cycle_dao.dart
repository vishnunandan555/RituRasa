import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../database/user_database_schema.dart';

/// Data Access Object for Cycle History and Period Logs in `riturasa_user.db`.
class CycleDao {
  final Database db;

  const CycleDao(this.db);

  /// Fetch all cycle log records, sorted by period start date descending.
  Future<Result<List<Map<String, dynamic>>>> getCycleLogs() async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tableCycleHistory,
        orderBy: 'period_start DESC',
      );
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch cycle logs: $e',
        cause: e,
      ));
    }
  }

  /// Fetch the most recent cycle start record.
  Future<Result<Map<String, dynamic>?>> getLatestCycleLog() async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tableCycleHistory,
        orderBy: 'period_start DESC',
        limit: 1,
      );
      if (rows.isEmpty) {
        return const Result.ok(null);
      }
      return Result.ok(rows.first);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch latest cycle log: $e',
        cause: e,
      ));
    }
  }

  /// Log a new period or cycle event.
  Future<Result<void>> insertCycleLog(Map<String, dynamic> logData) async {
    try {
      await db.insert(
        UserDatabaseSchema.tableCycleHistory,
        logData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to save cycle log: $e',
        cause: e,
      ));
    }
  }

  /// Delete a cycle log entry by ID.
  Future<Result<void>> deleteCycleLog(String id) async {
    try {
      await db.delete(
        UserDatabaseSchema.tableCycleHistory,
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to delete cycle log: $e',
        cause: e,
      ));
    }
  }
}
