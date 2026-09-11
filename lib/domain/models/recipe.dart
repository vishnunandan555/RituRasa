import 'package:equatable/equatable.dart';

/// Represents a single ingredient component within a recipe.
class RecipeIngredient extends Equatable {
  final String foodId;
  final String? foodName;
  final double quantity;
  final String unit;

  const RecipeIngredient({
    required this.foodId,
    this.foodName,
    required this.quantity,
    required this.unit,
  });

  @override
  List<Object?> get props => [foodId, foodName, quantity, unit];
}

/// Pure domain representation of a culinary recipe.
class RecipeItem extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? region;
  final String? country;
  final String? cuisine;
  final List<String> diet;
  final int? prepTimeMin;
  final int? cookTimeMin;
  final int? servings;
  final List<String> tags;
  final List<String> mealType;
  final List<String> instructions;
  final Map<String, double> nutritionPerServing;
  final List<RecipeIngredient> ingredients;

  const RecipeItem({
    required this.id,
    required this.name,
    this.description,
    this.region,
    this.country,
    this.cuisine,
    this.diet = const [],
    this.prepTimeMin,
    this.cookTimeMin,
    this.servings,
    this.tags = const [],
    this.mealType = const [],
    this.instructions = const [],
    this.nutritionPerServing = const {},
    this.ingredients = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        region,
        country,
        cuisine,
        diet,
        prepTimeMin,
        cookTimeMin,
        servings,
        tags,
        mealType,
        instructions,
        nutritionPerServing,
        ingredients,
      ];
}
