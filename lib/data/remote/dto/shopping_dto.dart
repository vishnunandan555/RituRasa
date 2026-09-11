/// Request DTO for remote shopping list generation.
class ShoppingListRequestDto {
  final List<String> selectedRecipeIds;
  final List<String> kitchenInventoryFoodIds;

  const ShoppingListRequestDto({
    required this.selectedRecipeIds,
    this.kitchenInventoryFoodIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'selected_recipe_ids': selectedRecipeIds,
      'kitchen_inventory_food_ids': kitchenInventoryFoodIds,
    };
  }
}

/// Item inside remote shopping list response.
class ShoppingListItemDto {
  final String foodId;
  final String foodName;
  final double quantity;
  final String unit;
  final List<String> sourceRecipeIds;

  const ShoppingListItemDto({
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.unit,
    this.sourceRecipeIds = const [],
  });

  factory ShoppingListItemDto.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return ShoppingListItemDto(
      foodId: json['food_id'] as String,
      foodName: json['food_name'] as String? ?? json['food_id'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'units',
      sourceRecipeIds: parseList(json['source_recipe_ids']),
    );
  }
}

/// Response DTO from SimpleNutriAPI for shopping list.
class ShoppingListResponseDto {
  final List<ShoppingListItemDto> items;
  final int missingItemCount;

  const ShoppingListResponseDto({
    required this.items,
    required this.missingItemCount,
  });

  factory ShoppingListResponseDto.fromJson(Map<String, dynamic> json) {
    final List<ShoppingListItemDto> itemList = [];
    if (json['items'] is List) {
      for (final i in json['items']) {
        if (i is Map<String, dynamic>) {
          itemList.add(ShoppingListItemDto.fromJson(i));
        }
      }
    }

    return ShoppingListResponseDto(
      items: itemList,
      missingItemCount: (json['missing_item_count'] as num?)?.toInt() ?? itemList.length,
    );
  }
}
