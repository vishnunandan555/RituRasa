import '../../../core/utils/result.dart';
import '../models/food.dart';

/// Repository interface for foods and nutritional composition.
abstract class IFoodRepository {
  Future<Result<List<FoodItem>>> searchFoods(String query, {int limit = 50});
  Future<Result<FoodItem>> getFoodById(String foodId);
  Future<Result<List<FoodItem>>> getFoodsByIds(List<String> foodIds);
  Future<Result<List<NutrientAmount>>> getFoodNutrients(String foodId);
  Future<Result<List<FoodItem>>> getFoodsByCategory(String category, {int limit = 100});
}
