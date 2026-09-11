import 'package:sqflite/sqflite.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../database/user_database_schema.dart';

/// Data Access Object for Shopping List in `riturasa_user.db`.
class ShoppingDao {
  final Database db;

  const ShoppingDao(this.db);

  /// Fetch full active shopping checklist.
  Future<Result<List<Map<String, dynamic>>>> getShoppingList() async {
    try {
      final rows = await db.query(
        UserDatabaseSchema.tableShoppingList,
        orderBy: 'is_checked ASC, updated_at DESC',
      );
      return Result.ok(rows);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to fetch shopping list: $e',
        cause: e,
      ));
    }
  }

  /// Add or update a shopping item by ID or food_id.
  Future<Result<void>> upsertItem(Map<String, dynamic> itemData) async {
    try {
      await db.insert(
        UserDatabaseSchema.tableShoppingList,
        itemData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to save shopping item: $e',
        cause: e,
      ));
    }
  }

  /// Toggle item checked status (0 = unchecked, 1 = checked).
  Future<Result<void>> toggleChecked(String id, bool isChecked) async {
    try {
      await db.update(
        UserDatabaseSchema.tableShoppingList,
        {
          'is_checked': isChecked ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to update shopping item status: $e',
        cause: e,
      ));
    }
  }

  /// Delete a single shopping item.
  Future<Result<void>> deleteItem(String id) async {
    try {
      await db.delete(
        UserDatabaseSchema.tableShoppingList,
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to delete shopping item: $e',
        cause: e,
      ));
    }
  }

  /// Remove all checked items from the list.
  Future<Result<void>> removeChecked() async {
    try {
      await db.delete(
        UserDatabaseSchema.tableShoppingList,
        where: 'is_checked = 1',
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to remove checked shopping items: $e',
        cause: e,
      ));
    }
  }

  /// Clear the entire shopping list.
  Future<Result<void>> clearAll() async {
    try {
      await db.delete(UserDatabaseSchema.tableShoppingList);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure(
        message: 'Failed to clear shopping list: $e',
        cause: e,
      ));
    }
  }
}
