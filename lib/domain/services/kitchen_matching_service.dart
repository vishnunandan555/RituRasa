import '../models/recipe.dart';
import '../models/recommendation.dart';

/// Standalone local recipe ranking and kitchen inventory matching engine.
class KitchenMatchingService {
  const KitchenMatchingService();

  /// Rank a list of recipes based on available kitchen foods and target nutritional tags.
  List<RankedRecipeItem> rankRecipes({
    required List<RecipeItem> recipes,
    required List<String> availableFoodIds,
    List<String> targetTags = const [],
    String? dietFilter,
    String? cuisineFilter,
    String? mealTypeFilter,
  }) {
    final availableSet = availableFoodIds.map((e) => e.toLowerCase().trim()).toSet();
    final targetTagSet = targetTags.map((e) => e.toLowerCase().trim()).toSet();

    final List<RankedRecipeItem> ranked = [];

    for (final recipe in recipes) {
      // Optional diet filter
      if (dietFilter != null && dietFilter.isNotEmpty) {
        final matchesDiet = recipe.diet.any((d) => d.toLowerCase() == dietFilter.toLowerCase());
        if (!matchesDiet) continue;
      }

      // Optional cuisine filter
      if (cuisineFilter != null && cuisineFilter.isNotEmpty) {
        if (recipe.cuisine?.toLowerCase() != cuisineFilter.toLowerCase()) continue;
      }

      // Optional meal type filter
      if (mealTypeFilter != null && mealTypeFilter.isNotEmpty) {
        final matchesMeal = recipe.mealType.any((m) => m.toLowerCase() == mealTypeFilter.toLowerCase());
        if (!matchesMeal) continue;
      }

      final ingredients = recipe.ingredients;
      final matched = <RecipeIngredient>[];
      final missing = <RecipeIngredient>[];

      for (final ing in ingredients) {
        if (availableSet.contains(ing.foodId.toLowerCase().trim())) {
          matched.add(ing);
        } else {
          missing.add(ing);
        }
      }

      final totalCount = ingredients.isEmpty ? 1 : ingredients.length;
      final matchPercentage = (matched.length / totalCount) * 100.0;

      // Calculate tag overlap with active cycle phase priorities
      final recipeTags = recipe.tags.map((t) => t.toLowerCase().trim()).toSet();
      final tagOverlapCount = recipeTags.intersection(targetTagSet).length;

      // Composite scoring formula (matches SimpleNutriAPI logic)
      final score = (matchPercentage * 0.6) + (tagOverlapCount * 8.0) - (missing.length * 5.0);

      ranked.add(RankedRecipeItem(
        recipe: recipe,
        matchPercentage: double.parse(matchPercentage.toStringAsFixed(1)),
        matchedCount: matched.length,
        score: double.parse(score.toStringAsFixed(1)),
        missingIngredients: missing,
      ));
    }

    // Sort descending by score; secondary sort by match percentage
    ranked.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return b.matchPercentage.compareTo(a.matchPercentage);
    });

    return ranked;
  }
}
