import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';

/// Data Access Object for taxonomies, metadata, and nutrient definitions in `nutrition_reference.db`.
class TaxonomyDao {
  final Database db;

  const TaxonomyDao(this.db);

  /// Fetch all system food categories.
  Future<Result<List<Map<String, dynamic>>>> getCategories() async {
    try {
      final rows = await db.query('categories', orderBy: 'name ASC');
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch categories: $e',
        cause: e,
      ));
    }
  }

  /// Fetch all cuisines.
  Future<Result<List<Map<String, dynamic>>>> getCuisines() async {
    try {
      final rows = await db.query('cuisines', orderBy: 'name ASC');
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch cuisines: $e',
        cause: e,
      ));
    }
  }

  /// Fetch all geographical regions.
  Future<Result<List<Map<String, dynamic>>>> getRegions() async {
    try {
      final rows = await db.query('regions', orderBy: 'name ASC');
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch regions: $e',
        cause: e,
      ));
    }
  }

  /// Fetch all diet types (Vegetarian, Vegan, Non-Veg, etc.).
  Future<Result<List<Map<String, dynamic>>>> getDietTypes() async {
    try {
      final rows = await db.query('diet_types', orderBy: 'name ASC');
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch diet types: $e',
        cause: e,
      ));
    }
  }

  /// Fetch master nutrient catalog.
  Future<Result<List<Map<String, dynamic>>>> getNutrients() async {
    try {
      final rows = await db.query('nutrients', orderBy: 'name ASC');
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch nutrients: $e',
        cause: e,
      ));
    }
  }
}
