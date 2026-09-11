import 'dart:convert';
import '../../core/utils/result.dart';
import '../../domain/models/recipe.dart';
import '../../domain/repositories/i_recipe_repository.dart';
import '../local/dao/recipe_dao.dart';
import '../remote/api/simple_nutri_api_service.dart';
import '../remote/mappers/recipe_mapper.dart';

class RecipeRepositoryImpl implements IRecipeRepository {
  final RecipeDao recipeDao;
  final SimpleNutriApiService? apiService;

  const RecipeRepositoryImpl({
    required this.recipeDao,
    this.apiService,
  });

  @override
  Future<Result<List<RecipeItem>>> getAllRecipes({int limit = 200}) async {
    final localResult = await recipeDao.getAllRecipes(limit: limit);
    return localResult.map((rows) => rows.map(_fromDbRow).toList());
  }

  @override
  Future<Result<RecipeItem>> getRecipeById(String recipeId) async {
    final localResult = await recipeDao.getRecipeById(recipeId);
    if (localResult.isOk) {
      final recipe = _fromDbRow(localResult.valueOrNull!);
      // Fetch ingredients
      final ingResult = await recipeDao.getRecipeIngredients(recipeId);
      final ingredients = (ingResult.valueOrNull ?? []).map((i) {
        return RecipeIngredient(
          foodId: i['food_id'] as String,
          foodName: i['food_name'] as String?,
          quantity: (i['quantity'] as num).toDouble(),
          unit: i['unit'] as String? ?? 'units',
        );
      }).toList();

      return Result.ok(RecipeItem(
        id: recipe.id,
        name: recipe.name,
        description: recipe.description,
        region: recipe.region,
        country: recipe.country,
        cuisine: recipe.cuisine,
        diet: recipe.diet,
        prepTimeMin: recipe.prepTimeMin,
        cookTimeMin: recipe.cookTimeMin,
        servings: recipe.servings,
        tags: recipe.tags,
        mealType: recipe.mealType,
        instructions: recipe.instructions,
        nutritionPerServing: recipe.nutritionPerServing,
        ingredients: ingredients,
      ));
    }

    // Remote fallback
    if (apiService != null) {
      final remoteResult = await apiService!.fetchRecipe(recipeId);
      if (remoteResult.isOk) {
        return Result.ok(RecipeMapper.toDomain(remoteResult.valueOrNull!));
      }
    }

    return Result.err(localResult.failureOrNull!);
  }

  @override
  Future<Result<List<RecipeItem>>> searchRecipes({
    List<String>? tags,
    String? cuisine,
    String? region,
    String? mealType,
    int limit = 50,
  }) async {
    final localResult = await recipeDao.searchRecipes(
      tags: tags,
      cuisine: cuisine,
      region: region,
      mealType: mealType,
      limit: limit,
    );

    return localResult.map((rows) => rows.map(_fromDbRow).toList());
  }

  RecipeItem _fromDbRow(Map<String, dynamic> row) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      try {
        final decoded = jsonDecode(raw.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    final Map<String, double> nutMap = {};
    try {
      final decoded = jsonDecode(row['nutrition_per_serving_json']?.toString() ?? '{}');
      if (decoded is Map) {
        decoded.forEach((k, v) {
          if (v is num) nutMap[k.toString()] = v.toDouble();
        });
      }
    } catch (_) {}

    return RecipeItem(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      region: row['region'] as String?,
      country: row['country'] as String?,
      cuisine: row['cuisine'] as String?,
      diet: parseList(row['diet_json']),
      prepTimeMin: (row['prep_time_min'] as num?)?.toInt(),
      cookTimeMin: (row['cook_time_min'] as num?)?.toInt(),
      servings: (row['servings'] as num?)?.toInt(),
      tags: parseList(row['tags_json']),
      mealType: parseList(row['meal_type_json']),
      instructions: parseList(row['instructions_json']),
      nutritionPerServing: nutMap,
    );
  }
}
