/// DTO for Recipe ingredient component.
class RecipeIngredientDto {
  final String foodId;
  final String? foodName;
  final double quantity;
  final String unit;

  const RecipeIngredientDto({
    required this.foodId,
    this.foodName,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredientDto.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientDto(
      foodId: json['food_id'] as String,
      foodName: json['food_name'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'units',
    );
  }
}

/// DTO for Recipe from SimpleNutriAPI.
class RecipeDto {
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
  final List<RecipeIngredientDto> ingredients;

  const RecipeDto({
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

  factory RecipeDto.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    final Map<String, double> nutMap = {};
    if (json['nutrition_per_serving'] is Map) {
      (json['nutrition_per_serving'] as Map).forEach((k, v) {
        if (v is num) nutMap[k.toString()] = v.toDouble();
      });
    }

    final List<RecipeIngredientDto> ings = [];
    if (json['ingredients'] is List) {
      for (final i in json['ingredients']) {
        if (i is Map<String, dynamic>) {
          ings.add(RecipeIngredientDto.fromJson(i));
        }
      }
    }

    return RecipeDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      cuisine: json['cuisine'] as String?,
      diet: parseList(json['diet'] ?? json['diet_json']),
      prepTimeMin: (json['prep_time_min'] as num?)?.toInt(),
      cookTimeMin: (json['cook_time_min'] as num?)?.toInt(),
      servings: (json['servings'] as num?)?.toInt(),
      tags: parseList(json['tags'] ?? json['tags_json']),
      mealType: parseList(json['meal_type'] ?? json['meal_type_json']),
      instructions: parseList(json['instructions'] ?? json['instructions_json']),
      nutritionPerServing: nutMap,
      ingredients: ings,
    );
  }
}

/// Request DTO for recipe ranking based on kitchen inventory and target tags.
class RecipeRankingRequestDto {
  final List<String> availableFoodIds;
  final List<String> targetTags;
  final String? diet;
  final String? cuisine;
  final String? region;
  final String? mealType;

  const RecipeRankingRequestDto({
    required this.availableFoodIds,
    this.targetTags = const [],
    this.diet,
    this.cuisine,
    this.region,
    this.mealType,
  });

  Map<String, dynamic> toJson() {
    return {
      'available_food_ids': availableFoodIds,
      'target_tags': targetTags,
      if (diet != null) 'diet': diet,
      if (cuisine != null) 'cuisine': cuisine,
      if (region != null) 'region': region,
      if (mealType != null) 'meal_type': mealType,
    };
  }
}

/// Response DTO item for ranked recipe.
class RankedRecipeDto {
  final String recipeId;
  final String recipeName;
  final String? cuisine;
  final int? servings;
  final int? prepTimeMin;
  final int? cookTimeMin;
  final List<String> mealType;
  final List<String> instructions;
  final Map<String, double> nutritionPerServing;
  final double matchPercentage;
  final int matchedCount;
  final List<RecipeIngredientDto> missingIngredients;
  final double score;

  const RankedRecipeDto({
    required this.recipeId,
    required this.recipeName,
    this.cuisine,
    this.servings,
    this.prepTimeMin,
    this.cookTimeMin,
    this.mealType = const [],
    this.instructions = const [],
    this.nutritionPerServing = const {},
    required this.matchPercentage,
    required this.matchedCount,
    this.missingIngredients = const [],
    required this.score,
  });

  factory RankedRecipeDto.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    final Map<String, double> nutMap = {};
    if (json['nutrition_per_serving'] is Map) {
      (json['nutrition_per_serving'] as Map).forEach((k, v) {
        if (v is num) nutMap[k.toString()] = v.toDouble();
      });
    }

    final List<RecipeIngredientDto> missing = [];
    if (json['missing_ingredients'] is List) {
      for (final m in json['missing_ingredients']) {
        if (m is Map<String, dynamic>) {
          missing.add(RecipeIngredientDto.fromJson(m));
        }
      }
    }

    return RankedRecipeDto(
      recipeId: json['recipe_id'] as String,
      recipeName: json['recipe_name'] as String,
      cuisine: json['cuisine'] as String?,
      servings: (json['servings'] as num?)?.toInt(),
      prepTimeMin: (json['prep_time_min'] as num?)?.toInt(),
      cookTimeMin: (json['cook_time_min'] as num?)?.toInt(),
      mealType: parseList(json['meal_type']),
      instructions: parseList(json['instructions']),
      nutritionPerServing: nutMap,
      matchPercentage: (json['match_percentage'] as num?)?.toDouble() ?? 0.0,
      matchedCount: (json['matched_count'] as num?)?.toInt() ?? 0,
      missingIngredients: missing,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
