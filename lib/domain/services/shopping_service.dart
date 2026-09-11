import 'package:uuid/uuid.dart';
import '../models/kitchen_item.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';

/// Standalone local service to compute missing ingredients across recipes and deduplicate shopping lists.
class ShoppingService {
  static const _uuid = Uuid();

  const ShoppingService();

  /// Generate consolidated shopping items from recipes, deducting available kitchen quantities.
  List<ShoppingListItem> generateMissingIngredients({
    required List<RecipeItem> selectedRecipes,
    required List<KitchenItem> kitchenInventory,
  }) {
    // Map available food_id -> total available quantity in kitchen
    final Map<String, double> kitchenStock = {};
    for (final item in kitchenInventory) {
      final key = item.foodId.toLowerCase().trim();
      kitchenStock[key] = (kitchenStock[key] ?? 0.0) + item.quantity;
    }

    // Accumulator for required ingredients: food_id -> (name, totalNeeded, unit, Set<recipeId>)
    final Map<String, (String, double, String, Set<String>)> requiredMap = {};

    for (final recipe in selectedRecipes) {
      for (final ing in recipe.ingredients) {
        final key = ing.foodId.toLowerCase().trim();
        final name = ing.foodName ?? ing.foodId;
        final unit = ing.unit;

        if (requiredMap.containsKey(key)) {
          final existing = requiredMap[key]!;
          final updatedQty = existing.$2 + ing.quantity;
          final updatedRecipes = Set<String>.from(existing.$4)..add(recipe.id);
          requiredMap[key] = (existing.$1, updatedQty, unit, updatedRecipes);
        } else {
          requiredMap[key] = (name, ing.quantity, unit, {recipe.id});
        }
      }
    }

    final List<ShoppingListItem> missingItems = [];
    final now = DateTime.now();

    requiredMap.forEach((foodId, tuple) {
      final (name, totalNeeded, unit, recipeIds) = tuple;
      final availableQty = kitchenStock[foodId] ?? 0.0;
      final deficit = totalNeeded - availableQty;

      if (deficit > 0) {
        missingItems.add(ShoppingListItem(
          id: 'shop_${_uuid.v4()}',
          foodId: foodId,
          name: name,
          quantity: double.parse(deficit.toStringAsFixed(1)),
          unit: unit,
          sourceRecipeIds: recipeIds.toList(),
          isChecked: false,
          createdAt: now,
          updatedAt: now,
        ));
      }
    });

    return missingItems;
  }
}
