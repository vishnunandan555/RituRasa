import '../../../domain/models/food.dart';
import '../../../domain/models/recommendation.dart';
import '../dto/food_dto.dart';

/// Maps raw Food DTOs to clean domain models.
class FoodMapper {
  FoodMapper._();

  static FoodItem toDomain(FoodDto dto) {
    return FoodItem(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      scientificName: dto.scientificName,
      category: dto.category,
      regions: dto.regions,
      cuisines: dto.cuisines,
      diet: dto.diet,
      tags: dto.tags,
      basisG: dto.basisG,
      energyKcal: dto.energyKcal,
      proteinG: dto.proteinG,
      carbohydrateG: dto.carbohydrateG,
      fatG: dto.fatG,
      fiberG: dto.fiberG,
      ironMg: dto.ironMg,
      calciumMg: dto.calciumMg,
      magnesiumMg: dto.magnesiumMg,
      zincMg: dto.zincMg,
      potassiumMg: dto.potassiumMg,
      sodiumMg: dto.sodiumMg,
      folateUg: dto.folateUg,
      vitaminCMg: dto.vitaminCMg,
      vitaminB6Mg: dto.vitaminB6Mg,
    );
  }

  static RankedFoodItem toRankedDomain(FoodRecommendationItemDto dto) {
    return RankedFoodItem(
      food: FoodItem(
        id: dto.foodId,
        name: dto.foodName,
        category: dto.category,
        energyKcal: dto.nutrients['energy_kcal'],
        proteinG: dto.nutrients['protein_g'],
        ironMg: dto.nutrients['iron_mg'],
        calciumMg: dto.nutrients['calcium_mg'],
        magnesiumMg: dto.nutrients['magnesium_mg'],
        zincMg: dto.nutrients['zinc_mg'],
        fiberG: dto.nutrients['fiber_g'],
      ),
      score: dto.score,
      matchReasons: dto.matchReasons,
    );
  }
}
