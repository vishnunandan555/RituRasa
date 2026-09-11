import '../../../core/utils/result.dart';
import 'api_client.dart';
import '../dto/cycle_dto.dart';
import '../dto/food_dto.dart';
import '../dto/health_dto.dart';
import '../dto/recipe_dto.dart';
import '../dto/shopping_dto.dart';

/// Typed client service communicating with SimpleNutriAPI endpoints.
class SimpleNutriApiService {
  final ApiClient apiClient;

  const SimpleNutriApiService(this.apiClient);

  /// Health and dataset version probe.
  Future<Result<HealthCheckDto>> fetchHealth() async {
    final result = await apiClient.get<Map<String, dynamic>>('/health');
    return result.map(HealthCheckDto.fromJson);
  }

  /// Fetch list of foods.
  Future<Result<List<FoodDto>>> fetchFoods({int limit = 50, int offset = 0}) async {
    final result = await apiClient.get<dynamic>(
      '/api/v1/foods',
      queryParameters: {'limit': limit, 'offset': offset},
    );

    return result.map((data) {
      if (data is List) {
        return data.map((e) => FoodDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    });
  }

  /// Search foods by query string.
  Future<Result<List<FoodDto>>> searchFoods(String query, {int limit = 50}) async {
    final result = await apiClient.get<dynamic>(
      '/api/v1/foods/search',
      queryParameters: {'q': query, 'limit': limit},
    );

    return result.map((data) {
      if (data is List) {
        return data.map((e) => FoodDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    });
  }

  /// Fetch food details by canonical ID.
  Future<Result<FoodDto>> fetchFood(String id) async {
    final result = await apiClient.get<Map<String, dynamic>>('/api/v1/foods/$id');
    return result.map(FoodDto.fromJson);
  }

  /// Fetch list of curated recipes.
  Future<Result<List<RecipeDto>>> fetchRecipes({int limit = 50, int offset = 0}) async {
    final result = await apiClient.get<dynamic>(
      '/api/v1/recipes',
      queryParameters: {'limit': limit, 'offset': offset},
    );

    return result.map((data) {
      if (data is List) {
        return data.map((e) => RecipeDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    });
  }

  /// Fetch single recipe by ID.
  Future<Result<RecipeDto>> fetchRecipe(String id) async {
    final result = await apiClient.get<Map<String, dynamic>>('/api/v1/recipes/$id');
    return result.map(RecipeDto.fromJson);
  }

  /// Fetch supportive priorities for all cycle phases.
  Future<Result<List<CyclePhaseResponseDto>>> fetchCyclePhases() async {
    final result = await apiClient.get<dynamic>('/api/v1/cycle/phases');
    return result.map((data) {
      if (data is List) {
        return data.map((e) => CyclePhaseResponseDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    });
  }

  /// Estimate current cycle phase and biological priorities.
  Future<Result<CyclePhaseResponseDto>> estimateCyclePhase(
    CycleEstimateRequestDto request,
  ) async {
    final result = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/cycle/estimate',
      data: request.toJson(),
    );
    return result.map(CyclePhaseResponseDto.fromJson);
  }

  /// Rank recipes dynamically by kitchen match and nutrition target tags.
  Future<Result<List<RankedRecipeDto>>> recommendRecipes(
    RecipeRankingRequestDto request,
  ) async {
    final result = await apiClient.post<dynamic>(
      '/api/v1/recommendations/recipes',
      data: request.toJson(),
    );

    return result.map((data) {
      if (data is List) {
        return data.map((e) => RankedRecipeDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    });
  }

  /// Rank foods by 6-factor SRS prioritization formula.
  Future<Result<List<FoodRecommendationItemDto>>> recommendFoods(
    FoodRecommendationRequestDto request,
  ) async {
    final result = await apiClient.post<dynamic>(
      '/api/v1/recommendations/foods',
      data: request.toJson(),
    );

    return result.map((data) {
      if (data is List) {
        return data
            .map((e) => FoodRecommendationItemDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    });
  }

  /// Generate deduplicated shopping list for selected recipes against kitchen inventory.
  Future<Result<ShoppingListResponseDto>> generateShoppingList(
    ShoppingListRequestDto request,
  ) async {
    final result = await apiClient.post<Map<String, dynamic>>(
      '/api/v1/recommendations/shopping-list',
      data: request.toJson(),
    );
    return result.map(ShoppingListResponseDto.fromJson);
  }
}
