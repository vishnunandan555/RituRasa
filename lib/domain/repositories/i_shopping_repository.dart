import '../../../core/utils/result.dart';
import '../models/shopping_item.dart';

/// Repository interface for shopping checklist.
abstract class IShoppingRepository {
  Future<Result<List<ShoppingListItem>>> getShoppingList();
  Future<Result<void>> addItem(ShoppingListItem item);
  Future<Result<void>> addItems(List<ShoppingListItem> items);
  Future<Result<void>> toggleChecked(String id, bool isChecked);
  Future<Result<void>> deleteItem(String id);
  Future<Result<void>> removeChecked();
  Future<Result<void>> clearAll();
}
