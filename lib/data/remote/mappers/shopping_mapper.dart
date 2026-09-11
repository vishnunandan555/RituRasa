import 'package:uuid/uuid.dart';
import '../../../domain/models/shopping_item.dart';
import '../dto/shopping_dto.dart';

/// Maps ShoppingListResponseDto to domain models.
class ShoppingMapper {
  ShoppingMapper._();

  static const _uuid = Uuid();

  static ShoppingListItem toDomain(ShoppingListItemDto dto) {
    final now = DateTime.now();
    return ShoppingListItem(
      id: 'remote_${_uuid.v4()}',
      foodId: dto.foodId,
      name: dto.foodName,
      quantity: dto.quantity,
      unit: dto.unit,
      sourceRecipeIds: dto.sourceRecipeIds,
      isChecked: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}
