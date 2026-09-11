import '../../core/utils/result.dart';
import '../models/recommendation.dart';
import '../repositories/i_cycle_repository.dart';
import '../repositories/i_food_repository.dart';
import '../repositories/i_kitchen_repository.dart';
import '../repositories/i_profile_repository.dart';
import '../repositories/i_recipe_repository.dart';
import '../../data/remote/api/simple_nutri_api_service.dart';
import '../../data/remote/dto/recipe_dto.dart';
import '../../data/remote/mappers/recipe_mapper.dart';
import 'cycle_service.dart';
import 'kitchen_matching_service.dart';

/// Orchestration engine for "What Should I Eat?".
/// Coordinates Profile, Cycle, Kitchen pantry, and Recipe/Food knowledge.
/// Fully operational offline with transparent remote enrichment when online.
class RecommendationEngine {
  final IProfileRepository profileRepository;
  final ICycleRepository cycleRepository;
  final IKitchenRepository kitchenRepository;
  final IRecipeRepository recipeRepository;
  final IFoodRepository foodRepository;
  final CycleService cycleService;
  final KitchenMatchingService kitchenMatchingService;
  final SimpleNutriApiService? apiService;

  const RecommendationEngine({
    required this.profileRepository,
    required this.cycleRepository,
    required this.kitchenRepository,
    required this.recipeRepository,
    required this.foodRepository,
    this.cycleService = const CycleService(),
    this.kitchenMatchingService = const KitchenMatchingService(),
    this.apiService,
  });

  /// Generate personalized meal recommendations.
  Future<Result<RecommendationResult>> getRecommendations({
    bool forceRemote = false,
  }) async {
    // 1. Resolve Profile & Diet
    final profileRes = await profileRepository.getProfile();
    final profile = profileRes.valueOrNull;

    // 2. Resolve Cycle Context
    final cycleLogRes = await cycleRepository.getLatestCycleLog();
    final latestLog = cycleLogRes.valueOrNull;

    // Default to today or recent period start if not yet logged
    final periodStart = latestLog?.periodStart ?? DateTime.now().subtract(const Duration(days: 7));
    final cycleLength = latestLog?.cycleLength ?? 28;

    final cycleStateRes = cycleService.calculateCycleState(
      lastPeriodStart: periodStart,
      cycleLength: cycleLength,
    );

    if (cycleStateRes.isErr) {
      return Result.err(cycleStateRes.failureOrNull!);
    }

    final cycleState = cycleStateRes.valueOrNull!;
    final phaseInfo = cycleState.phaseInfo;

    // 3. Resolve Kitchen Inventory
    final kitchenRes = await kitchenRepository.getInventory();
    final kitchenItems = kitchenRes.valueOrNull ?? [];
    final availableFoodIds = kitchenItems.map((k) => k.foodId).toList();

    // 4. Remote Enrichment Path (if online and requested/available)
    if (apiService != null && forceRemote) {
      try {
        final remoteRanked = await apiService!.recommendRecipes(
          RecipeRankingRequestDto(
            availableFoodIds: availableFoodIds,
            targetTags: phaseInfo.targetTags,
            diet: profile?.dietType.name,
            cuisine: profile?.cuisine,
            region: profile?.region,
          ),
        );

        if (remoteRanked.isOk && remoteRanked.valueOrNull!.isNotEmpty) {
          final rankedRecipes = remoteRanked.valueOrNull!.map(RecipeMapper.toRankedDomain).toList();
          return Result.ok(RecommendationResult(
            cyclePhase: phaseInfo,
            rankedRecipes: rankedRecipes,
            generatedAt: DateTime.now(),
            isOfflineResult: false,
          ));
        }
      } catch (_) {
        // Fall back gracefully to local offline scoring
      }
    }

    // 5. Authoritative Offline Path
    final recipesRes = await recipeRepository.getAllRecipes(limit: 150);
    final allRecipes = recipesRes.valueOrNull ?? [];

    final localRanked = kitchenMatchingService.rankRecipes(
      recipes: allRecipes,
      availableFoodIds: availableFoodIds,
      targetTags: phaseInfo.targetTags,
      dietFilter: profile?.dietType.name,
      cuisineFilter: profile?.cuisine.isNotEmpty == true ? profile?.cuisine : null,
    );

    return Result.ok(RecommendationResult(
      cyclePhase: phaseInfo,
      rankedRecipes: localRanked,
      generatedAt: DateTime.now(),
      isOfflineResult: true,
    ));
  }
}
