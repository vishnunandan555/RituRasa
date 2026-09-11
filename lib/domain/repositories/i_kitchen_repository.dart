import '../../../core/utils/result.dart';
import '../models/kitchen_item.dart';

/// Repository interface for kitchen inventory.
abstract class IKitchenRepository {
  Future<Result<List<KitchenItem>>> getInventory();
  Future<Result<void>> addItem(KitchenItem item);
  Future<Result<void>> updateItemQuantity(String foodId, double quantity);
  Future<Result<void>> removeItem(String foodId);
  Future<Result<void>> clearInventory();
}
