import '../../../core/utils/result.dart';
import '../models/recipe.dart';

/// Repository interface for culinary recipes and ingredients.
abstract class IRecipeRepository {
  Future<Result<List<RecipeItem>>> getAllRecipes({int limit = 200});
  Future<Result<RecipeItem>> getRecipeById(String recipeId);
  Future<Result<List<RecipeItem>>> searchRecipes({
    List<String>? tags,
    String? cuisine,
    String? region,
    String? mealType,
    int limit = 50,
  });
}
