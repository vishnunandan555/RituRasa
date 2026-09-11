import 'package:flutter_test/flutter_test.dart';
import 'package:riturasa/domain/models/kitchen_item.dart';
import 'package:riturasa/domain/models/recipe.dart';
import 'package:riturasa/domain/services/shopping_service.dart';

void main() {
  const service = ShoppingService();

  group('ShoppingService Unit Tests', () {
    final now = DateTime.now();

    final recipe1 = RecipeItem(
      id: 'r_ladoo',
      name: 'Sesame Ladoo',
      ingredients: const [
        RecipeIngredient(foodId: 'sesame_seeds', foodName: 'Sesame Seeds', quantity: 150, unit: 'g'),
        RecipeIngredient(foodId: 'jaggery', foodName: 'Jaggery', quantity: 100, unit: 'g'),
      ],
    );

    final recipe2 = RecipeItem(
      id: 'r_chikki',
      name: 'Peanut Chikki',
      ingredients: const [
        RecipeIngredient(foodId: 'peanuts', foodName: 'Peanuts', quantity: 200, unit: 'g'),
        RecipeIngredient(foodId: 'jaggery', foodName: 'Jaggery', quantity: 150, unit: 'g'),
      ],
    );

    test('Consolidates duplicate ingredients and deducts kitchen inventory', () {
      final kitchen = [
        KitchenItem(
          id: 'k1',
          foodId: 'jaggery',
          quantity: 50.0, // Has 50g jaggery in stock
          unit: 'g',
          addedAt: now,
          updatedAt: now,
        ),
        KitchenItem(
          id: 'k2',
          foodId: 'peanuts',
          quantity: 200.0, // Has all 200g peanuts in stock
          unit: 'g',
          addedAt: now,
          updatedAt: now,
        ),
      ];

      final missing = service.generateMissingIngredients(
        selectedRecipes: [recipe1, recipe2],
        kitchenInventory: kitchen,
      );

      // Peanuts: Needed 200g, has 200g -> Deficit = 0 (Should NOT appear)
      expect(missing.any((i) => i.foodId == 'peanuts'), isFalse);

      // Sesame seeds: Needed 150g, has 0g -> Deficit = 150g
      final sesame = missing.firstWhere((i) => i.foodId == 'sesame_seeds');
      expect(sesame.quantity, equals(150.0));
      expect(sesame.sourceRecipeIds, equals(['r_ladoo']));

      // Jaggery: Needed 100 + 150 = 250g, has 50g -> Deficit = 200g
      final jaggery = missing.firstWhere((i) => i.foodId == 'jaggery');
      expect(jaggery.quantity, equals(200.0));
      expect(jaggery.sourceRecipeIds, containsAll(['r_ladoo', 'r_chikki']));
    });
  });
}
