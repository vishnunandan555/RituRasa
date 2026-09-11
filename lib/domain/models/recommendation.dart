import 'package:equatable/equatable.dart';
import 'cycle.dart';
import 'food.dart';
import 'recipe.dart';

/// Recipe ranked by kitchen availability and phase nutrient alignment.
class RankedRecipeItem extends Equatable {
  final RecipeItem recipe;
  final double matchPercentage;
  final int matchedCount;
  final double score;
  final List<RecipeIngredient> missingIngredients;

  const RankedRecipeItem({
    required this.recipe,
    required this.matchPercentage,
    required this.matchedCount,
    required this.score,
    this.missingIngredients = const [],
  });

  @override
  List<Object?> get props => [recipe, matchPercentage, matchedCount, score, missingIngredients];
}

/// Food ranked by 6-factor nutritional prioritization formula.
class RankedFoodItem extends Equatable {
  final FoodItem food;
  final double score;
  final List<String> matchReasons;

  const RankedFoodItem({
    required this.food,
    required this.score,
    this.matchReasons = const [],
  });

  @override
  List<Object?> get props => [food, score, matchReasons];
}

/// Complete recommendation package produced for "What Should I Eat?".
class RecommendationResult extends Equatable {
  final CyclePhaseInfo cyclePhase;
  final List<RankedRecipeItem> rankedRecipes;
  final List<RankedFoodItem> rankedFoods;
  final DateTime generatedAt;
  final bool isOfflineResult;

  const RecommendationResult({
    required this.cyclePhase,
    required this.rankedRecipes,
    this.rankedFoods = const [],
    required this.generatedAt,
    this.isOfflineResult = true,
  });

  @override
  List<Object?> get props => [cyclePhase, rankedRecipes, rankedFoods, generatedAt, isOfflineResult];
}
