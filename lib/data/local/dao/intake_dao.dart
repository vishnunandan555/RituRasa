import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../database/user_database_schema.dart';

/// Data Access Object for Daily Food Intake and Daily Nutrient Totals in `riturasa_user.db`.
class IntakeDao {
  final Database db;

  const IntakeDao(this.db);

  /// Log a consumed food or recipe entry.
  Future<Result<void>> logIntake(Map<String, dynamic> intakeData) async {
    try {
      await db.insert(
        UserDatabaseSchema.tableDailyIntake,
        intakeData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to log food intake: $e',
        cause: e,
      ));
    }
  }

  /// Get all logged entries for a specific calendar date (YYYY-MM-DD).
  Future<Result<List<Map<String, dynamic>>>> getIntakesForDate(String date) async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tableDailyIntake,
        where: 'date = ?',
        whereArgs: [date],
        orderBy: 'logged_at ASC',
      );
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch intake entries for date $date: $e',
        cause: e,
      ));
    }
  }

  /// Delete a single logged intake entry by ID.
  Future<Result<void>> deleteIntake(String id) async {
    try {
      await db.delete(
        UserDatabaseSchema.tableDailyIntake,
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to delete intake entry: $e',
        cause: e,
      ));
    }
  }

  /// Fetch logged entries across a date range.
  Future<Result<List<Map<String, dynamic>>>> getDateRangeIntakes(
    String startDate,
    String endDate,
  ) async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tableDailyIntake,
        where: 'date >= ? AND date <= ?',
        whereArgs: [startDate, endDate],
        orderBy: 'date ASC, logged_at ASC',
      );
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch date range intakes: $e',
        cause: e,
      ));
    }
  }

  /// Fetch calculated daily nutrient totals for a given date.
  Future<Result<Map<String, dynamic>?>> getDailyNutrientTotals(String date) async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tableDailyNutrientTotals,
        where: 'date = ?',
        whereArgs: [date],
        limit: 1,
      );
      if (rows.isEmpty) {
        return const Result.ok(null);
      }
      return Result.ok(rows.first);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch daily nutrient totals: $e',
        cause: e,
      ));
    }
  }

  /// Persist or update aggregated daily nutrient totals.
  Future<Result<void>> upsertDailyNutrientTotals(Map<String, dynamic> totalsData) async {
    try {
      await db.insert(
        UserDatabaseSchema.tableDailyNutrientTotals,
        totalsData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to save daily nutrient totals: $e',
        cause: e,
      ));
    }
  }
}
