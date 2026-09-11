import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';

/// Data Access Object for Foods in `nutrition_reference.db`.
class FoodDao {
  final Database db;

  const FoodDao(this.db);

  /// Full-text search on foods using SQLite FTS5 (`foods_fts`).
  /// Searches food names, aliases, and tags.
  Future<Result<List<Map<String, dynamic>>>> searchFoods(
    String query, {
    int limit = 50,
  }) async {
    try {
      final sanitized = query.trim().replaceAll('"', '""');
      if (sanitized.isEmpty) {
        return const Result.ok([]);
      }

      // SQLite FTS5 prefix match
      final ftsQuery = '$sanitized*';

      final results = await db.rawQuery('''
        SELECT f.* 
        FROM foods f
        JOIN foods_fts fts ON f.id = fts.food_id
        WHERE foods_fts MATCH ?
        LIMIT ?
      ''', [ftsQuery, limit]);

      if (results.isNotEmpty) {
        return Result.ok(results);
      }

      // Fallback: substring search with LIKE if FTS produced 0 results
      final fallbackResults = await db.rawQuery('''
        SELECT DISTINCT f.*
        FROM foods f
        LEFT JOIN food_aliases a ON f.id = a.food_id
        WHERE f.name LIKE ? OR a.alias LIKE ? OR f.id LIKE ?
        LIMIT ?
      ''', ['%$sanitized%', '%$sanitized%', '%$sanitized%', limit]);

      return Result.ok(fallbackResults);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to search foods: $e',
        cause: e,
      ));
    }
  }

  /// Fetch a single canonical food by its ID.
  Future<Result<Map<String, dynamic>>> getFoodById(String foodId) async {
    try {
      final rows = await db.query(
        'foods',
        where: 'id = ?',
        whereArgs: [foodId],
        limit: 1,
      );

      if (rows.isEmpty) {
        return Result.err(NotFoundFailure(
          message: 'Food with id "$foodId" not found in reference database.',
        ));
      }

      return Result.ok(rows.first);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch food by id: $e',
        cause: e,
      ));
    }
  }

  /// Get multiple foods by their IDs.
  Future<Result<List<Map<String, dynamic>>>> getFoodsByIds(List<String> foodIds) async {
    try {
      if (foodIds.isEmpty) return const Result.ok([]);
      final placeholders = List.filled(foodIds.length, '?').join(',');
      final rows = await db.rawQuery(
        'SELECT * FROM foods WHERE id IN ($placeholders)',
        foodIds,
      );
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch foods by ids: $e',
        cause: e,
      ));
    }
  }

  /// Fetch all aliases for a specific food.
  Future<Result<List<String>>> getFoodAliases(String foodId) async {
    try {
      final rows = await db.query(
        'food_aliases',
        columns: ['alias'],
        where: 'food_id = ?',
        whereArgs: [foodId],
      );
      final aliases = rows.map((r) => r['alias'] as String).toList();
      return Result.ok(aliases);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch food aliases: $e',
        cause: e,
      ));
    }
  }

  /// Fetch detailed nutrient composition rows for a food.
  Future<Result<List<Map<String, dynamic>>>> getFoodNutrients(String foodId) async {
    try {
      final rows = await db.rawQuery('''
        SELECT fn.*, n.name as nutrient_name, n.unit as nutrient_unit, n.category as nutrient_category
        FROM food_nutrients fn
        JOIN nutrients n ON fn.nutrient_id = n.id
        WHERE fn.food_id = ?
        ORDER BY fn.amount DESC
      ''', [foodId]);

      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch food nutrients: $e',
        cause: e,
      ));
    }
  }

  /// Fetch foods belonging to a specific category.
  Future<Result<List<Map<String, dynamic>>>> getFoodsByCategory(
    String category, {
    int limit = 100,
  }) async {
    try {
      final rows = await db.query(
        'foods',
        where: 'category = ?',
        whereArgs: [category],
        limit: limit,
      );
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch foods by category: $e',
        cause: e,
      ));
    }
  }
}
