import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/local/dao/cycle_dao.dart';
import '../../data/local/dao/food_dao.dart';
import '../../data/local/dao/intake_dao.dart';
import '../../data/local/dao/kitchen_dao.dart';
import '../../data/local/dao/profile_dao.dart';
import '../../data/local/dao/recipe_dao.dart';
import '../../data/local/dao/shopping_dao.dart';
import '../../data/local/dao/sync_metadata_dao.dart';
import '../../data/local/dao/taxonomy_dao.dart';
import '../../data/remote/api/api_client.dart';
import '../../data/remote/api/simple_nutri_api_service.dart';
import '../../data/repositories/cycle_repository_impl.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../data/repositories/intake_repository_impl.dart';
import '../../data/repositories/kitchen_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../data/repositories/shopping_repository_impl.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/repositories/i_cycle_repository.dart';
import '../../domain/repositories/i_food_repository.dart';
import '../../domain/repositories/i_intake_repository.dart';
import '../../domain/repositories/i_kitchen_repository.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../../domain/repositories/i_recipe_repository.dart';
import '../../domain/repositories/i_shopping_repository.dart';
import '../../domain/repositories/i_sync_repository.dart';
import '../../domain/services/cycle_service.dart';
import '../../domain/services/kitchen_matching_service.dart';
import '../../domain/services/nutrition_progress_service.dart';
import '../../domain/services/recommendation_engine.dart';
import '../../domain/services/shopping_service.dart';
import '../../domain/services/sync_service.dart';
import '../database/database_manager.dart';
import '../database/initial_data_seeder.dart';

// --- Database Providers ---
final databaseManagerProvider = Provider<DatabaseManager>((ref) {
  return DatabaseManager.instance;
});

final referenceDatabaseProvider = FutureProvider<Database>((ref) async {
  final dbManager = ref.watch(databaseManagerProvider);
  final res = await dbManager.getReferenceDatabase();
  return res.fold(
    onOk: (db) => db,
    onErr: (f) => throw Exception(f.message),
  );
});

final userDatabaseProvider = FutureProvider<Database>((ref) async {
  final dbManager = ref.watch(databaseManagerProvider);
  final res = await dbManager.getUserDatabase();
  return res.fold(
    onOk: (db) async {
      await InitialDataSeeder(dbManager).seedIfEmpty();
      return db;
    },
    onErr: (f) => throw Exception(f.message),
  );
});

final initialDataSeederProvider = Provider<InitialDataSeeder>((ref) {
  final dbManager = ref.watch(databaseManagerProvider);
  return InitialDataSeeder(dbManager);
});

// --- DAO Providers ---
final foodDaoProvider = FutureProvider<FoodDao>((ref) async {
  final db = await ref.watch(referenceDatabaseProvider.future);
  return FoodDao(db);
});

final recipeDaoProvider = FutureProvider<RecipeDao>((ref) async {
  final db = await ref.watch(referenceDatabaseProvider.future);
  return RecipeDao(db);
});

final taxonomyDaoProvider = FutureProvider<TaxonomyDao>((ref) async {
  final db = await ref.watch(referenceDatabaseProvider.future);
  return TaxonomyDao(db);
});

final profileDaoProvider = FutureProvider<ProfileDao>((ref) async {
  final db = await ref.watch(userDatabaseProvider.future);
  return ProfileDao(db);
});

final cycleDaoProvider = FutureProvider<CycleDao>((ref) async {
  final db = await ref.watch(userDatabaseProvider.future);
  return CycleDao(db);
});

final kitchenDaoProvider = FutureProvider<KitchenDao>((ref) async {
  final db = await ref.watch(userDatabaseProvider.future);
  return KitchenDao(db);
});

final intakeDaoProvider = FutureProvider<IntakeDao>((ref) async {
  final db = await ref.watch(userDatabaseProvider.future);
  return IntakeDao(db);
});

final shoppingDaoProvider = FutureProvider<ShoppingDao>((ref) async {
  final db = await ref.watch(userDatabaseProvider.future);
  return ShoppingDao(db);
});

final syncMetadataDaoProvider = FutureProvider<SyncMetadataDao>((ref) async {
  final db = await ref.watch(userDatabaseProvider.future);
  return SyncMetadataDao(db);
});

// --- Remote Client Providers ---
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final simpleNutriApiServiceProvider = Provider<SimpleNutriApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return SimpleNutriApiService(client);
});

// --- Repository Providers ---
final profileRepositoryProvider = FutureProvider<IProfileRepository>((ref) async {
  final dao = await ref.watch(profileDaoProvider.future);
  return ProfileRepositoryImpl(dao);
});

final cycleRepositoryProvider = FutureProvider<ICycleRepository>((ref) async {
  final dao = await ref.watch(cycleDaoProvider.future);
  return CycleRepositoryImpl(dao);
});

final kitchenRepositoryProvider = FutureProvider<IKitchenRepository>((ref) async {
  final kDao = await ref.watch(kitchenDaoProvider.future);
  final fDao = await ref.watch(foodDaoProvider.future);
  return KitchenRepositoryImpl(kitchenDao: kDao, foodDao: fDao);
});

final foodRepositoryProvider = FutureProvider<IFoodRepository>((ref) async {
  final dao = await ref.watch(foodDaoProvider.future);
  final api = ref.watch(simpleNutriApiServiceProvider);
  return FoodRepositoryImpl(foodDao: dao, apiService: api);
});

final recipeRepositoryProvider = FutureProvider<IRecipeRepository>((ref) async {
  final dao = await ref.watch(recipeDaoProvider.future);
  final api = ref.watch(simpleNutriApiServiceProvider);
  return RecipeRepositoryImpl(recipeDao: dao, apiService: api);
});

final intakeRepositoryProvider = FutureProvider<IIntakeRepository>((ref) async {
  final dao = await ref.watch(intakeDaoProvider.future);
  return IntakeRepositoryImpl(dao);
});

final shoppingRepositoryProvider = FutureProvider<IShoppingRepository>((ref) async {
  final dao = await ref.watch(shoppingDaoProvider.future);
  return ShoppingRepositoryImpl(dao);
});

final syncRepositoryProvider = FutureProvider<ISyncRepository>((ref) async {
  final dao = await ref.watch(syncMetadataDaoProvider.future);
  final api = ref.watch(simpleNutriApiServiceProvider);
  return SyncRepositoryImpl(syncMetadataDao: dao, apiService: api);
});

// --- Domain Service Providers ---
final cycleServiceProvider = Provider<CycleService>((ref) {
  return const CycleService();
});

final kitchenMatchingServiceProvider = Provider<KitchenMatchingService>((ref) {
  return const KitchenMatchingService();
});

final nutritionProgressServiceProvider = Provider<NutritionProgressService>((ref) {
  return const NutritionProgressService();
});

final shoppingServiceProvider = Provider<ShoppingService>((ref) {
  return const ShoppingService();
});

final syncServiceProvider = FutureProvider<SyncService>((ref) async {
  final repo = await ref.watch(syncRepositoryProvider.future);
  return SyncService(repo);
});

final recommendationEngineProvider = FutureProvider<RecommendationEngine>((ref) async {
  final profileRepo = await ref.watch(profileRepositoryProvider.future);
  final cycleRepo = await ref.watch(cycleRepositoryProvider.future);
  final kitchenRepo = await ref.watch(kitchenRepositoryProvider.future);
  final recipeRepo = await ref.watch(recipeRepositoryProvider.future);
  final foodRepo = await ref.watch(foodRepositoryProvider.future);
  final cycleService = ref.watch(cycleServiceProvider);
  final kitchenService = ref.watch(kitchenMatchingServiceProvider);
  final apiService = ref.watch(simpleNutriApiServiceProvider);

  return RecommendationEngine(
    profileRepository: profileRepo,
    cycleRepository: cycleRepo,
    kitchenRepository: kitchenRepo,
    recipeRepository: recipeRepo,
    foodRepository: foodRepo,
    cycleService: cycleService,
    kitchenMatchingService: kitchenService,
    apiService: apiService,
  );
});
