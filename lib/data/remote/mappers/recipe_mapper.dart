import '../../../domain/models/recipe.dart';
import '../../../domain/models/recommendation.dart';
import '../dto/recipe_dto.dart';

/// Maps raw Recipe DTOs to clean domain models.
class RecipeMapper {
  RecipeMapper._();

  static RecipeIngredient ingredientToDomain(RecipeIngredientDto dto) {
    return RecipeIngredient(
      foodId: dto.foodId,
      foodName: dto.foodName,
      quantity: dto.quantity,
      unit: dto.unit,
    );
  }

  static RecipeItem toDomain(RecipeDto dto) {
    return RecipeItem(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      region: dto.region,
      country: dto.country,
      cuisine: dto.cuisine,
      diet: dto.diet,
      prepTimeMin: dto.prepTimeMin,
      cookTimeMin: dto.cookTimeMin,
      servings: dto.servings,
      tags: dto.tags,
      mealType: dto.mealType,
      instructions: dto.instructions,
      nutritionPerServing: dto.nutritionPerServing,
      ingredients: dto.ingredients.map(ingredientToDomain).toList(),
    );
  }

  static RankedRecipeItem toRankedDomain(RankedRecipeDto dto) {
    return RankedRecipeItem(
      recipe: RecipeItem(
        id: dto.recipeId,
        name: dto.recipeName,
        cuisine: dto.cuisine,
        servings: dto.servings,
        prepTimeMin: dto.prepTimeMin,
        cookTimeMin: dto.cookTimeMin,
        mealType: dto.mealType,
        instructions: dto.instructions,
        nutritionPerServing: dto.nutritionPerServing,
      ),
      matchPercentage: dto.matchPercentage,
      matchedCount: dto.matchedCount,
      score: dto.score,
      missingIngredients: dto.missingIngredients.map(ingredientToDomain).toList(),
    );
  }
}
