import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../database/user_database_schema.dart';

/// Data Access Object for Kitchen Inventory in `riturasa_user.db`.
class KitchenDao {
  final Database db;

  const KitchenDao(this.db);

  /// Fetch all kitchen inventory items.
  Future<Result<List<Map<String, dynamic>>>> getInventory() async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tableKitchenInventory,
        orderBy: 'updated_at DESC',
      );
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch kitchen inventory: $e',
        cause: e,
      ));
    }
  }

  /// Add or update an inventory item by canonical food_id.
  Future<Result<void>> addOrUpdateItem(Map<String, dynamic> itemData) async {
    try {
      await db.insert(
        UserDatabaseSchema.tableKitchenInventory,
        itemData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to update kitchen inventory item: $e',
        cause: e,
      ));
    }
  }

  /// Remove an item from the kitchen by food_id.
  Future<Result<void>> removeItem(String foodId) async {
    try {
      await db.delete(
        UserDatabaseSchema.tableKitchenInventory,
        where: 'food_id = ?',
        whereArgs: [foodId],
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to remove kitchen inventory item: $e',
        cause: e,
      ));
    }
  }

  /// Clear the entire kitchen inventory.
  Future<Result<void>> clearInventory() async {
    try {
      await db.delete(UserDatabaseSchema.tableKitchenInventory);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to clear kitchen inventory: $e',
        cause: e,
      ));
    }
  }
}
