import 'package:flutter_test/flutter_test.dart';
import 'package:riturasa/domain/models/recipe.dart';
import 'package:riturasa/domain/services/kitchen_matching_service.dart';

void main() {
  const service = KitchenMatchingService();

  group('KitchenMatchingService Unit Tests', () {
    final recipeA = RecipeItem(
      id: 'r_dosa',
      name: 'Ragi Dosa',
      cuisine: 'South Indian',
      tags: const ['iron', 'calcium', 'breakfast'],
      diet: const ['vegetarian', 'vegan'],
      ingredients: const [
        RecipeIngredient(foodId: 'ragi', quantity: 100, unit: 'g'),
        RecipeIngredient(foodId: 'rice', quantity: 50, unit: 'g'),
        RecipeIngredient(foodId: 'urad_dal', quantity: 25, unit: 'g'),
      ],
    );

    final recipeB = RecipeItem(
      id: 'r_spinach_dal',
      name: 'Spinach Dal',
      cuisine: 'Indian',
      tags: const ['iron', 'folate', 'lunch'],
      diet: const ['vegetarian', 'vegan'],
      ingredients: const [
        RecipeIngredient(foodId: 'spinach', quantity: 1, unit: 'bunch'),
        RecipeIngredient(foodId: 'toor_dal', quantity: 100, unit: 'g'),
        RecipeIngredient(foodId: 'tomato', quantity: 2, unit: 'pcs'),
      ],
    );

    test('100% kitchen match scores higher than partial match', () {
      final ranked = service.rankRecipes(
        recipes: [recipeA, recipeB],
        availableFoodIds: ['ragi', 'rice', 'urad_dal'], // Has all ingredients for Dosa
        targetTags: ['iron'],
      );

      expect(ranked.length, equals(2));
      expect(ranked.first.recipe.id, equals('r_dosa'));
      expect(ranked.first.matchPercentage, equals(100.0));
      expect(ranked.first.missingIngredients.isEmpty, isTrue);

      expect(ranked.last.recipe.id, equals('r_spinach_dal'));
      expect(ranked.last.matchPercentage, equals(0.0));
      expect(ranked.last.missingIngredients.length, equals(3));
    });

    test('Target tags overlap boosts ranking score', () {
      final rankedWithTags = service.rankRecipes(
        recipes: [recipeA, recipeB],
        availableFoodIds: ['ragi', 'spinach'],
        targetTags: ['folate'], // Matches recipeB tags
      );

      final recipeBScore = rankedWithTags.firstWhere((r) => r.recipe.id == 'r_spinach_dal').score;
      final rankedWithoutTags = service.rankRecipes(
        recipes: [recipeA, recipeB],
        availableFoodIds: ['ragi', 'spinach'],
        targetTags: [],
      );
      final recipeBScoreWithout = rankedWithoutTags.firstWhere((r) => r.recipe.id == 'r_spinach_dal').score;

      expect(recipeBScore, greaterThan(recipeBScoreWithout));
    });

    test('Diet filter eliminates non-matching recipes', () {
      final nonVegRecipe = RecipeItem(
        id: 'r_chicken',
        name: 'Chicken Curry',
        diet: const ['non-vegetarian'],
        ingredients: const [RecipeIngredient(foodId: 'chicken', quantity: 500, unit: 'g')],
      );

      final ranked = service.rankRecipes(
        recipes: [recipeA, nonVegRecipe],
        availableFoodIds: ['chicken', 'ragi'],
        dietFilter: 'vegetarian',
      );

      expect(ranked.length, equals(1));
      expect(ranked.first.recipe.id, equals('r_dosa'));
    });
  });
}
