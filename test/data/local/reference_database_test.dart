import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:riturasa/data/local/dao/food_dao.dart';
import 'package:riturasa/data/local/dao/recipe_dao.dart';
import 'package:riturasa/data/local/dao/taxonomy_dao.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database refDb;
  late FoodDao foodDao;
  late RecipeDao recipeDao;
  late TaxonomyDao taxonomyDao;

  setUp(() async {
    final file = File('assets/database/nutrition_reference.db');
    expect(file.existsSync(), isTrue, reason: 'Bundled nutrition_reference.db must exist');

    refDb = await databaseFactoryFfi.openDatabase(
      file.absolute.path,
      options: OpenDatabaseOptions(readOnly: true),
    );

    foodDao = FoodDao(refDb);
    recipeDao = RecipeDao(refDb);
    taxonomyDao = TaxonomyDao(refDb);
  });

  tearDown(() async {
    await refDb.close();
  });

  group('Reference Database & DAOs Tests (Real Bundled Database)', () {
    test('FoodDao: searchFoods uses FTS5 to find ragi and millets', () async {
      final searchResult = await foodDao.searchFoods('ragi');
      expect(searchResult.isOk, isTrue);
      final foods = searchResult.valueOrNull ?? [];
      expect(foods.isNotEmpty, isTrue);
      expect(foods.any((f) => (f['name'] as String).toLowerCase().contains('ragi') || (f['id'] as String).contains('ragi')), isTrue);
    });

    test('FoodDao: getFoodById returns canonical food record and nutrients', () async {
      final foodRes = await foodDao.getFoodById('a010_ragi');
      expect(foodRes.isOk, isTrue);
      final food = foodRes.valueOrNull!;
      expect(food['name'], equals('Ragi'));
      expect((food['calcium_mg'] as num).toDouble(), greaterThan(300.0));

      final nutrientsRes = await foodDao.getFoodNutrients('a010_ragi');
      expect(nutrientsRes.isOk, isTrue);
      final nutrients = nutrientsRes.valueOrNull!;
      expect(nutrients.isNotEmpty, isTrue);
    });

    test('RecipeDao: getAllRecipes and getRecipeIngredients', () async {
      final allRecipesRes = await recipeDao.getAllRecipes(limit: 10);
      expect(allRecipesRes.isOk, isTrue);
      final recipes = allRecipesRes.valueOrNull!;
      expect(recipes.isNotEmpty, isTrue);

      final firstRecipeId = recipes.first['id'] as String;
      final ingredientsRes = await recipeDao.getRecipeIngredients(firstRecipeId);
      expect(ingredientsRes.isOk, isTrue);
      expect(ingredientsRes.valueOrNull!.isNotEmpty, isTrue);
    });

    test('TaxonomyDao: fetch categories, cuisines, regions, and nutrients', () async {
      final catRes = await taxonomyDao.getCategories();
      expect(catRes.isOk, isTrue);
      expect(catRes.valueOrNull!.isNotEmpty, isTrue);

      final cuiRes = await taxonomyDao.getCuisines();
      expect(cuiRes.isOk, isTrue);
      expect(cuiRes.valueOrNull!.isNotEmpty, isTrue);

      final nutRes = await taxonomyDao.getNutrients();
      expect(nutRes.isOk, isTrue);
      expect(nutRes.valueOrNull!.isNotEmpty, isTrue);
    });
  });
}
