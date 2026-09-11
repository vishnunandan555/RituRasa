import '../../core/utils/result.dart';
import '../../domain/models/kitchen_item.dart';
import '../../domain/repositories/i_kitchen_repository.dart';
import '../local/dao/food_dao.dart';
import '../local/dao/kitchen_dao.dart';

class KitchenRepositoryImpl implements IKitchenRepository {
  final KitchenDao kitchenDao;
  final FoodDao? foodDao;

  const KitchenRepositoryImpl({
    required this.kitchenDao,
    this.foodDao,
  });

  @override
  Future<Result<List<KitchenItem>>> getInventory() async {
    final result = await kitchenDao.getInventory();
    return result.map((rows) {
      return rows.map((r) {
        return KitchenItem(
          id: r['id'] as String,
          foodId: r['food_id'] as String,
          foodName: r['custom_name'] as String? ?? 'Food Item',
          quantity: (r['quantity'] as num).toDouble(),
          unit: r['unit'] as String? ?? 'units',
          addedAt: DateTime.tryParse(r['added_at']?.toString() ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(r['updated_at']?.toString() ?? '') ?? DateTime.now(),
          expiresAt: r['expires_at'] != null ? DateTime.tryParse(r['expires_at'] as String) : null,
        );
      }).toList();
    });
  }

  @override
  Future<Result<void>> addItem(KitchenItem item) async {
    return await kitchenDao.addOrUpdateItem({
      'id': item.id,
      'food_id': item.foodId,
      'custom_name': item.foodName,
      'quantity': item.quantity,
      'unit': item.unit,
      'added_at': item.addedAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
      'expires_at': item.expiresAt?.toIso8601String(),
    });
  }

  @override
  Future<Result<void>> updateItemQuantity(String foodId, double quantity) async {
    final now = DateTime.now().toIso8601String();
    return await kitchenDao.updateQuantity(foodId, quantity, now);
  }

  @override
  Future<Result<void>> removeItem(String foodId) async {
    return await kitchenDao.removeItem(foodId);
  }

  @override
  Future<Result<void>> clearInventory() async {
    return await kitchenDao.clearInventory();
  }
}
