import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:riturasa/data/local/database/user_database_schema.dart';
import 'package:riturasa/data/local/dao/profile_dao.dart';
import 'package:riturasa/data/local/dao/cycle_dao.dart';
import 'package:riturasa/data/local/dao/kitchen_dao.dart';
import 'package:riturasa/data/local/dao/food_dao.dart';
import 'package:riturasa/data/local/dao/recipe_dao.dart';
import 'package:riturasa/data/remote/api/api_client.dart';
import 'package:riturasa/data/remote/api/simple_nutri_api_service.dart';
import 'package:riturasa/data/repositories/profile_repository_impl.dart';
import 'package:riturasa/data/repositories/cycle_repository_impl.dart';
import 'package:riturasa/data/repositories/kitchen_repository_impl.dart';
import 'package:riturasa/data/repositories/food_repository_impl.dart';
import 'package:riturasa/data/repositories/recipe_repository_impl.dart';
import 'package:riturasa/domain/services/recommendation_engine.dart';

class MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database userDb;
  late Database refDb;
  late MockDio mockDio;
  late SimpleNutriApiService mockApiService;

  late RecommendationEngine recommendationEngine;
  late FoodRepositoryImpl foodRepo;

  setUp(() async {
    userDb = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: UserDatabaseSchema.currentVersion,
        onCreate: UserDatabaseSchema.onCreate,
      ),
    );

    final refFile = File('assets/database/nutrition_reference.db');
    refDb = await databaseFactoryFfi.openDatabase(
      refFile.absolute.path,
      options: OpenDatabaseOptions(readOnly: true),
    );

    mockDio = MockDio();
    when(() => mockDio.interceptors).thenReturn(Interceptors());
    mockApiService = SimpleNutriApiService(ApiClient(customDio: mockDio));

    final profileDao = ProfileDao(userDb);
    final cycleDao = CycleDao(userDb);
    final kitchenDao = KitchenDao(userDb);
    final foodDao = FoodDao(refDb);
    final recipeDao = RecipeDao(refDb);

    final profileRepo = ProfileRepositoryImpl(profileDao);
    final cycleRepo = CycleRepositoryImpl(cycleDao);
    final kitchenRepo = KitchenRepositoryImpl(kitchenDao: kitchenDao, foodDao: foodDao);
    foodRepo = FoodRepositoryImpl(foodDao: foodDao, apiService: mockApiService);
    final recipeRepo = RecipeRepositoryImpl(recipeDao: recipeDao, apiService: mockApiService);

    recommendationEngine = RecommendationEngine(
      profileRepository: profileRepo,
      cycleRepository: cycleRepo,
      kitchenRepository: kitchenRepo,
      recipeRepository: recipeRepo,
      foodRepository: foodRepo,
      apiService: mockApiService,
    );
  });

  tearDown(() async {
    await userDb.close();
    await refDb.close();
  });

  group('Resilient Online Fallback Integration Tests (Flow B & C)', () {
    test('When remote API times out, RecommendationEngine gracefully falls back to local scoring', () async {
      // Simulate remote API timeout
      when(() => mockDio.post<dynamic>(
            '/api/v1/recommendations/recipes',
            data: any(named: 'data'),
            options: any(named: 'options'),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/recommendations/recipes'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await recommendationEngine.getRecommendations(forceRemote: true);

      // Must succeed cleanly without rethrowing DioException!
      expect(result.isOk, isTrue);
      final rec = result.valueOrNull!;
      expect(rec.isOfflineResult, isTrue);
      expect(rec.rankedRecipes.isNotEmpty, isTrue);
    });

    test('FoodRepository search returns local results even when remote is unreachable', () async {
      // Searching a common food found locally in nutrition_reference.db
      final result = await foodRepo.searchFoods('ragi');
      expect(result.isOk, isTrue);
      expect(result.valueOrNull!.isNotEmpty, isTrue);
    });
  });
}
