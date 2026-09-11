/// DTO representing raw Food from SimpleNutriAPI.
class FoodDto {
  final String id;
  final String? code;
  final String name;
  final String? scientificName;
  final String category;
  final List<String> regions;
  final List<String> cuisines;
  final List<String> diet;
  final List<String> tags;
  final double basisG;
  final double? energyKcal;
  final double? proteinG;
  final double? carbohydrateG;
  final double? fatG;
  final double? fiberG;
  final double? ironMg;
  final double? calciumMg;
  final double? magnesiumMg;
  final double? zincMg;
  final double? potassiumMg;
  final double? sodiumMg;
  final double? folateUg;
  final double? vitaminCMg;
  final double? vitaminB6Mg;

  const FoodDto({
    required this.id,
    this.code,
    required this.name,
    this.scientificName,
    required this.category,
    this.regions = const [],
    this.cuisines = const [],
    this.diet = const [],
    this.tags = const [],
    this.basisG = 100.0,
    this.energyKcal,
    this.proteinG,
    this.carbohydrateG,
    this.fatG,
    this.fiberG,
    this.ironMg,
    this.calciumMg,
    this.magnesiumMg,
    this.zincMg,
    this.potassiumMg,
    this.sodiumMg,
    this.folateUg,
    this.vitaminCMg,
    this.vitaminB6Mg,
  });

  factory FoodDto.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    double? parseNum(dynamic val) => (val as num?)?.toDouble();

    return FoodDto(
      id: json['id'] as String,
      code: json['code'] as String?,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String?,
      category: json['category'] as String? ?? 'General',
      regions: parseStringList(json['regions'] ?? json['regions_json']),
      cuisines: parseStringList(json['cuisines'] ?? json['cuisines_json']),
      diet: parseStringList(json['diet'] ?? json['diet_json']),
      tags: parseStringList(json['tags'] ?? json['tags_json']),
      basisG: parseNum(json['basis_g']) ?? 100.0,
      energyKcal: parseNum(json['energy_kcal']),
      proteinG: parseNum(json['protein_g']),
      carbohydrateG: parseNum(json['carbohydrate_g']),
      fatG: parseNum(json['fat_g']),
      fiberG: parseNum(json['fiber_g']),
      ironMg: parseNum(json['iron_mg']),
      calciumMg: parseNum(json['calcium_mg']),
      magnesiumMg: parseNum(json['magnesium_mg']),
      zincMg: parseNum(json['zinc_mg']),
      potassiumMg: parseNum(json['potassium_mg']),
      sodiumMg: parseNum(json['sodium_mg']),
      folateUg: parseNum(json['folate_ug']),
      vitaminCMg: parseNum(json['vitamin_c_mg']),
      vitaminB6Mg: parseNum(json['vitamin_b6_mg']),
    );
  }
}

/// Request DTO for remote food recommendation.
class FoodRecommendationRequestDto {
  final List<String> targetTags;
  final String? diet;
  final String? region;
  final String? cuisine;
  final List<String> availableFoodIds;
  final List<String> excludedFoodIds;
  final List<String> preferredFoodIds;
  final int limit;

  const FoodRecommendationRequestDto({
    this.targetTags = const [],
    this.diet,
    this.region,
    this.cuisine,
    this.availableFoodIds = const [],
    this.excludedFoodIds = const [],
    this.preferredFoodIds = const [],
    this.limit = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'target_tags': targetTags,
      if (diet != null) 'diet': diet,
      if (region != null) 'region': region,
      if (cuisine != null) 'cuisine': cuisine,
      'available_food_ids': availableFoodIds,
      'excluded_food_ids': excludedFoodIds,
      'preferred_food_ids': preferredFoodIds,
      'limit': limit,
    };
  }
}

/// Response DTO item for ranked food recommendations.
class FoodRecommendationItemDto {
  final String foodId;
  final String foodName;
  final String category;
  final double score;
  final List<String> matchReasons;
  final Map<String, double> nutrients;

  const FoodRecommendationItemDto({
    required this.foodId,
    required this.foodName,
    required this.category,
    required this.score,
    this.matchReasons = const [],
    this.nutrients = const {},
  });

  factory FoodRecommendationItemDto.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    final Map<String, double> nutMap = {};
    if (json['nutrients'] is Map) {
      (json['nutrients'] as Map).forEach((k, v) {
        if (v is num) nutMap[k.toString()] = v.toDouble();
      });
    }

    return FoodRecommendationItemDto(
      foodId: json['food_id'] as String,
      foodName: json['food_name'] as String,
      category: json['category'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      matchReasons: parseList(json['match_reasons']),
      nutrients: nutMap,
    );
  }
}
