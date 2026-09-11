import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:riturasa/data/local/database/user_database_schema.dart';
import 'package:riturasa/data/local/dao/profile_dao.dart';
import 'package:riturasa/data/local/dao/cycle_dao.dart';
import 'package:riturasa/data/local/dao/kitchen_dao.dart';
import 'package:riturasa/data/local/dao/intake_dao.dart';
import 'package:riturasa/data/local/dao/shopping_dao.dart';
import 'package:riturasa/data/local/dao/food_dao.dart';
import 'package:riturasa/data/local/dao/recipe_dao.dart';
import 'package:riturasa/data/repositories/profile_repository_impl.dart';
import 'package:riturasa/data/repositories/cycle_repository_impl.dart';
import 'package:riturasa/data/repositories/kitchen_repository_impl.dart';
import 'package:riturasa/data/repositories/intake_repository_impl.dart';
import 'package:riturasa/data/repositories/shopping_repository_impl.dart';
import 'package:riturasa/data/repositories/food_repository_impl.dart';
import 'package:riturasa/data/repositories/recipe_repository_impl.dart';
import 'package:riturasa/domain/models/cycle.dart';
import 'package:riturasa/domain/models/intake_entry.dart';
import 'package:riturasa/domain/models/kitchen_item.dart';
import 'package:riturasa/domain/models/user_profile.dart';
import 'package:riturasa/domain/services/cycle_service.dart';
import 'package:riturasa/domain/services/kitchen_matching_service.dart';
import 'package:riturasa/domain/services/nutrition_progress_service.dart';
import 'package:riturasa/domain/services/recommendation_engine.dart';
import 'package:riturasa/domain/services/shopping_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database userDb;
  late Database refDb;

  late ProfileRepositoryImpl profileRepo;
  late CycleRepositoryImpl cycleRepo;
  late KitchenRepositoryImpl kitchenRepo;
  late IntakeRepositoryImpl intakeRepo;
  late ShoppingRepositoryImpl shoppingRepo;
  late FoodRepositoryImpl foodRepo;
  late RecipeRepositoryImpl recipeRepo;

  late RecommendationEngine recommendationEngine;
  const progressService = NutritionProgressService();
  const shoppingService = ShoppingService();

  setUp(() async {
    // 1. In-memory user database
    userDb = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: UserDatabaseSchema.currentVersion,
        onCreate: UserDatabaseSchema.onCreate,
      ),
    );

    // 2. Real bundled reference database
    final refFile = File('assets/database/nutrition_reference.db');
    refDb = await databaseFactoryFfi.openDatabase(
      refFile.absolute.path,
      options: OpenDatabaseOptions(readOnly: true),
    );

    final profileDao = ProfileDao(userDb);
    final cycleDao = CycleDao(userDb);
    final kitchenDao = KitchenDao(userDb);
    final intakeDao = IntakeDao(userDb);
    final shoppingDao = ShoppingDao(userDb);
    final foodDao = FoodDao(refDb);
    final recipeDao = RecipeDao(refDb);

    profileRepo = ProfileRepositoryImpl(profileDao);
    cycleRepo = CycleRepositoryImpl(cycleDao);
    kitchenRepo = KitchenRepositoryImpl(kitchenDao: kitchenDao, foodDao: foodDao);
    intakeRepo = IntakeRepositoryImpl(intakeDao);
    shoppingRepo = ShoppingRepositoryImpl(shoppingDao);
    foodRepo = FoodRepositoryImpl(foodDao: foodDao);
    recipeRepo = RecipeRepositoryImpl(recipeDao: recipeDao);

    recommendationEngine = RecommendationEngine(
      profileRepository: profileRepo,
      cycleRepository: cycleRepo,
      kitchenRepository: kitchenRepo,
      recipeRepository: recipeRepo,
      foodRepository: foodRepo,
      cycleService: const CycleService(),
      kitchenMatchingService: const KitchenMatchingService(),
    );
  });

  tearDown(() async {
    await userDb.close();
    await refDb.close();
  });

  group('End-to-End Offline Integration Test (Flow A)', () {
    test('Executes complete user lifecycle 100% offline from local databases', () async {
      final now = DateTime.now();

      // Step 1: Create user profile
      final profile = UserProfile(
        id: 'usr_offline',
        age: 27,
        dietType: DietType.vegetarian,
        region: 'South India',
        cuisine: 'South Indian',
        createdAt: now,
        updatedAt: now,
      );
      final saveProfRes = await profileRepo.saveProfile(profile);
      expect(saveProfRes.isOk, isTrue);

      final fetchedProfile = await profileRepo.getProfile();
      expect(fetchedProfile.valueOrNull?.id, equals('usr_offline'));
      expect(fetchedProfile.valueOrNull?.dietType, equals(DietType.vegetarian));

      // Step 2: Set cycle period (8 days ago -> Day 8 = Follicular Phase)
      final periodStart = now.subtract(const Duration(days: 7));
      final cycleLog = CycleRecord(
        id: 'cycle_1',
        periodStart: periodStart,
        cycleLength: 28,
        createdAt: now,
        updatedAt: now,
      );
      final saveCycleRes = await cycleRepo.saveCycleLog(cycleLog);
      expect(saveCycleRes.isOk, isTrue);

      // Step 3: Add ingredients to kitchen
      await kitchenRepo.addItem(KitchenItem(
        id: 'k1',
        foodId: 'a010_ragi',
        foodName: 'Ragi',
        quantity: 500,
        unit: 'g',
        addedAt: now,
        updatedAt: now,
      ));
      await kitchenRepo.addItem(KitchenItem(
        id: 'k2',
        foodId: 'rice',
        foodName: 'Rice',
        quantity: 1000,
        unit: 'g',
        addedAt: now,
        updatedAt: now,
      ));

      final kitchenList = await kitchenRepo.getInventory();
      expect(kitchenList.valueOrNull?.length, equals(2));

      // Step 4: Retrieve offline recommendations
      final recResult = await recommendationEngine.getRecommendations();
      expect(recResult.isOk, isTrue);
      final rec = recResult.valueOrNull!;

      expect(rec.isOfflineResult, isTrue);
      expect(rec.cyclePhase.phaseType, equals(CyclePhaseType.follicular));
      expect(rec.cyclePhase.priorityNutrientNames, contains('Protein'));
      expect(rec.rankedRecipes.isNotEmpty, isTrue);

      // Top recipe has matched ingredients
      final topRanked = rec.rankedRecipes.first;
      expect(topRanked.recipe.id, isNotEmpty);
      expect(topRanked.score, isNotNull);

      // Step 5: Log consumption of recipe ("I ate this")
      final todayStr = now.toIso8601String().substring(0, 10);
      final intakeEntry = IntakeEntry(
        id: 'log_1',
        date: todayStr,
        recipeId: topRanked.recipe.id,
        name: topRanked.recipe.name,
        quantity: 1.0,
        unit: 'serving',
        mealType: MealType.breakfast,
        nutrients: topRanked.recipe.nutritionPerServing,
        loggedAt: now,
      );

      final logRes = await intakeRepo.logIntake(intakeEntry);
      expect(logRes.isOk, isTrue);

      final loggedEntries = await intakeRepo.getIntakesForDate(todayStr);
      expect(loggedEntries.valueOrNull?.length, equals(1));
      expect(loggedEntries.valueOrNull?.first.name, equals(topRanked.recipe.name));

      // Step 6: Compute daily RDA progress
      final progressSummary = progressService.calculateDailyProgress(
        date: todayStr,
        intakes: loggedEntries.valueOrNull!,
      );
      expect(progressSummary.date, equals(todayStr));
      expect(progressSummary.progressMap.containsKey('iron_mg'), isTrue);
      expect(progressSummary.progressMap.containsKey('protein_g'), isTrue);

      // Persist calculated totals
      await intakeRepo.saveDailyNutrientTotals(progressSummary.totals);
      final savedTotals = await intakeRepo.getDailyNutrientTotals(todayStr);
      expect(savedTotals.valueOrNull, isNotNull);

      // Step 7: Generate missing ingredients and shopping list
      // Load full recipe with ingredients to calculate shopping deficit
      final fullRecipeRes = await recipeRepo.getRecipeById(topRanked.recipe.id);
      expect(fullRecipeRes.isOk, isTrue);

      final missingList = shoppingService.generateMissingIngredients(
        selectedRecipes: [fullRecipeRes.valueOrNull!],
        kitchenInventory: kitchenList.valueOrNull!,
      );

      if (missingList.isNotEmpty) {
        await shoppingRepo.addItems(missingList);
        var activeShopping = await shoppingRepo.getShoppingList();
        expect(activeShopping.valueOrNull?.isNotEmpty, isTrue);

        // Toggle checked state
        final firstItem = activeShopping.valueOrNull!.first;
        await shoppingRepo.toggleChecked(firstItem.id, true);

        activeShopping = await shoppingRepo.getShoppingList();
        final updatedItem = activeShopping.valueOrNull!.firstWhere((i) => i.id == firstItem.id);
        expect(updatedItem.isChecked, isTrue);
      }
    });
  });
}
