import 'dart:convert';
import '../../core/utils/result.dart';
import '../../domain/models/shopping_item.dart';
import '../../domain/repositories/i_shopping_repository.dart';
import '../local/dao/shopping_dao.dart';

class ShoppingRepositoryImpl implements IShoppingRepository {
  final ShoppingDao shoppingDao;

  const ShoppingRepositoryImpl(this.shoppingDao);

  @override
  Future<Result<List<ShoppingListItem>>> getShoppingList() async {
    final result = await shoppingDao.getShoppingList();
    return result.map((rows) {
      return rows.map((r) {
        List<String> parseList(dynamic raw) {
          if (raw == null) return [];
          try {
            final decoded = jsonDecode(raw.toString());
            if (decoded is List) return decoded.map((e) => e.toString()).toList();
          } catch (_) {}
          return [];
        }

        return ShoppingListItem(
          id: r['id'] as String,
          foodId: r['food_id'] as String,
          name: r['name'] as String,
          quantity: (r['quantity'] as num).toDouble(),
          unit: r['unit'] as String? ?? 'units',
          sourceRecipeIds: parseList(r['source_recipe_ids_json']),
          isChecked: (r['is_checked'] as int? ?? 0) == 1,
          createdAt: DateTime.tryParse(r['created_at']?.toString() ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(r['updated_at']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();
    });
  }

  @override
  Future<Result<void>> addItem(ShoppingListItem item) async {
    return await shoppingDao.upsertItem(_toMap(item));
  }

  @override
  Future<Result<void>> addItems(List<ShoppingListItem> items) async {
    for (final item in items) {
      final res = await shoppingDao.upsertItem(_toMap(item));
      if (res.isErr) return res;
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> toggleChecked(String id, bool isChecked) async {
    return await shoppingDao.toggleChecked(id, isChecked);
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    return await shoppingDao.deleteItem(id);
  }

  @override
  Future<Result<void>> removeChecked() async {
    return await shoppingDao.removeChecked();
  }

  @override
  Future<Result<void>> clearAll() async {
    return await shoppingDao.clearAll();
  }

  Map<String, dynamic> _toMap(ShoppingListItem item) {
    return {
      'id': item.id,
      'food_id': item.foodId,
      'name': item.name,
      'quantity': item.quantity,
      'unit': item.unit,
      'source_recipe_ids_json': jsonEncode(item.sourceRecipeIds),
      'is_checked': item.isChecked ? 1 : 0,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    };
  }
}
