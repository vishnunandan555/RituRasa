import 'dart:convert';
import '../../core/utils/result.dart';
import '../../domain/models/food.dart';
import '../../domain/repositories/i_food_repository.dart';
import '../local/dao/food_dao.dart';
import '../remote/api/simple_nutri_api_service.dart';
import '../remote/mappers/food_mapper.dart';

class FoodRepositoryImpl implements IFoodRepository {
  final FoodDao foodDao;
  final SimpleNutriApiService? apiService;

  const FoodRepositoryImpl({
    required this.foodDao,
    this.apiService,
  });

  @override
  Future<Result<List<FoodItem>>> searchFoods(String query, {int limit = 50}) async {
    final localResult = await foodDao.searchFoods(query, limit: limit);
    if (localResult.isOk && (localResult.valueOrNull?.isNotEmpty ?? false)) {
      final items = localResult.valueOrNull!.map(_fromDbRow).toList();
      return Result.ok(items);
    }

    // Remote fallback if local search yielded 0 results
    if (apiService != null) {
      final remoteResult = await apiService!.searchFoods(query, limit: limit);
      if (remoteResult.isOk) {
        final domainItems = remoteResult.valueOrNull!.map(FoodMapper.toDomain).toList();
        return Result.ok(domainItems);
      }
    }

    final items = (localResult.valueOrNull ?? []).map(_fromDbRow).toList();
    return Result.ok(items);
  }

  @override
  Future<Result<FoodItem>> getFoodById(String foodId) async {
    final localResult = await foodDao.getFoodById(foodId);
    if (localResult.isOk) {
      return Result.ok(_fromDbRow(localResult.valueOrNull!));
    }

    // Remote fallback
    if (apiService != null) {
      final remoteResult = await apiService!.fetchFood(foodId);
      if (remoteResult.isOk) {
        return Result.ok(FoodMapper.toDomain(remoteResult.valueOrNull!));
      }
    }

    return Result.err(localResult.failureOrNull!);
  }

  @override
  Future<Result<List<FoodItem>>> getFoodsByIds(List<String> foodIds) async {
    final localResult = await foodDao.getFoodsByIds(foodIds);
    return localResult.map((rows) => rows.map(_fromDbRow).toList());
  }

  @override
  Future<Result<List<NutrientAmount>>> getFoodNutrients(String foodId) async {
    final localResult = await foodDao.getFoodNutrients(foodId);
    return localResult.map((rows) {
      return rows.map((r) {
        return NutrientAmount(
          nutrientId: r['nutrient_id'] as String,
          name: r['nutrient_name'] as String? ?? r['nutrient_id'] as String,
          amount: (r['amount'] as num).toDouble(),
          unit: r['unit'] as String? ?? 'g',
          basisG: (r['basis_g'] as num?)?.toDouble() ?? 100.0,
        );
      }).toList();
    });
  }

  @override
  Future<Result<List<FoodItem>>> getFoodsByCategory(String category, {int limit = 100}) async {
    final localResult = await foodDao.getFoodsByCategory(category, limit: limit);
    return localResult.map((rows) => rows.map(_fromDbRow).toList());
  }

  FoodItem _fromDbRow(Map<String, dynamic> row) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      try {
        final decoded = jsonDecode(raw.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    double? parseNum(dynamic val) => (val as num?)?.toDouble();

    return FoodItem(
      id: row['id'] as String,
      code: row['code'] as String?,
      name: row['name'] as String,
      scientificName: row['scientific_name'] as String?,
      category: row['category'] as String,
      regions: parseList(row['regions_json']),
      cuisines: parseList(row['cuisines_json']),
      diet: parseList(row['diet_json']),
      tags: parseList(row['tags_json']),
      basisG: parseNum(row['basis_g']) ?? 100.0,
      energyKcal: parseNum(row['energy_kcal']),
      proteinG: parseNum(row['protein_g']),
      carbohydrateG: parseNum(row['carbohydrate_g']),
      fatG: parseNum(row['fat_g']),
      fiberG: parseNum(row['fiber_g']),
      ironMg: parseNum(row['iron_mg']),
      calciumMg: parseNum(row['calcium_mg']),
      magnesiumMg: parseNum(row['magnesium_mg']),
      zincMg: parseNum(row['zinc_mg']),
      potassiumMg: parseNum(row['potassium_mg']),
      sodiumMg: parseNum(row['sodium_mg']),
      folateUg: parseNum(row['folate_ug']),
      vitaminCMg: parseNum(row['vitamin_c_mg']),
      vitaminB6Mg: parseNum(row['vitamin_b6_mg']),
    );
  }
}
