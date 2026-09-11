import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';

/// Data Access Object for Recipes in `nutrition_reference.db`.
class RecipeDao {
  final Database db;

  const RecipeDao(this.db);

  /// Fetch all recipes with optional limit.
  Future<Result<List<Map<String, dynamic>>>> getAllRecipes({int limit = 200}) async {
    try {
      final rows = await db.query(
        'recipes',
        limit: limit,
        orderBy: 'name ASC',
      );
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch recipes: $e',
        cause: e,
      ));
    }
  }

  /// Fetch a single recipe by its canonical ID.
  Future<Result<Map<String, dynamic>>> getRecipeById(String recipeId) async {
    try {
      final rows = await db.query(
        'recipes',
        where: 'id = ?',
        whereArgs: [recipeId],
        limit: 1,
      );

      if (rows.isEmpty) {
        return Result.err(NotFoundFailure(
          message: 'Recipe with id "$recipeId" not found in reference database.',
        ));
      }

      return Result.ok(rows.first);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch recipe by id: $e',
        cause: e,
      ));
    }
  }

  /// Fetch all ingredients for a specific recipe with food names and units.
  Future<Result<List<Map<String, dynamic>>>> getRecipeIngredients(String recipeId) async {
    try {
      final rows = await db.rawQuery('''
        SELECT ri.*, f.name as food_name, f.category as food_category
        FROM recipe_ingredients ri
        LEFT JOIN foods f ON ri.food_id = f.id
        WHERE ri.recipe_id = ?
        ORDER BY ri.id ASC
      ''', [recipeId]);

      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch recipe ingredients: $e',
        cause: e,
      ));
    }
  }

  /// Search recipes matching optional dietary, cuisine, and tag filters.
  Future<Result<List<Map<String, dynamic>>>> searchRecipes({
    List<String>? tags,
    String? cuisine,
    String? region,
    String? mealType,
    int limit = 50,
  }) async {
    try {
      final List<String> whereClauses = [];
      final List<dynamic> whereArgs = [];

      if (cuisine != null && cuisine.isNotEmpty) {
        whereClauses.add('cuisine LIKE ?');
        whereArgs.add('%$cuisine%');
      }

      if (region != null && region.isNotEmpty) {
        whereClauses.add('region LIKE ?');
        whereArgs.add('%$region%');
      }

      final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      final rows = await db.query(
        'recipes',
        where: whereString,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        limit: limit,
      );

      // Post-filter on JSON columns if tags or mealType specified
      if (tags == null && mealType == null) {
        return Result.ok(rows);
      }

      final filtered = rows.where((row) {
        if (mealType != null && mealType.isNotEmpty) {
          try {
            final decodedMeal = jsonDecode(row['meal_type_json'].toString());
            if (decodedMeal is List) {
              final lowerMeal = decodedMeal.map((e) => e.toString().toLowerCase()).toSet();
              if (!lowerMeal.contains(mealType.toLowerCase())) {
                return false;
              }
            }
          } catch (_) {}
        }

        if (tags != null && tags.isNotEmpty) {
          try {
            final decodedTags = jsonDecode(row['tags_json'].toString());
            if (decodedTags is List) {
              final lowerRowTags = decodedTags.map((e) => e.toString().toLowerCase()).toSet();
              final hasMatchingTag = tags.any((t) => lowerRowTags.contains(t.toLowerCase()));
              if (!hasMatchingTag) return false;
            }
          } catch (_) {}
        }

        return true;
      }).toList();

      return Result.ok(filtered);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to search recipes: $e',
        cause: e,
      ));
    }
  }
}
