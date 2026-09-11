import 'package:flutter_test/flutter_test.dart';
import 'package:riturasa/data/remote/dto/cycle_dto.dart';
import 'package:riturasa/data/remote/dto/food_dto.dart';
import 'package:riturasa/data/remote/dto/health_dto.dart';
import 'package:riturasa/data/remote/dto/recipe_dto.dart';
import 'package:riturasa/data/remote/dto/shopping_dto.dart';
import 'package:riturasa/data/remote/mappers/cycle_mapper.dart';
import 'package:riturasa/data/remote/mappers/food_mapper.dart';
import 'package:riturasa/data/remote/mappers/recipe_mapper.dart';
import 'package:riturasa/data/remote/mappers/shopping_mapper.dart';

void main() {
  group('Remote DTO & Mapper Unit Tests', () {
    test('HealthCheckDto parses status and version', () {
      final json = {'status': 'ok', 'version': '1.0.0', 'dataset_version': '1.2.0'};
      final dto = HealthCheckDto.fromJson(json);
      expect(dto.status, equals('ok'));
      expect(dto.version, equals('1.0.0'));
      expect(dto.datasetVersion, equals('1.2.0'));
    });

    test('FoodDto and FoodMapper map correctly to domain FoodItem', () {
      final json = {
        'id': 'a010_ragi',
        'name': 'Ragi',
        'category': 'Millets',
        'regions_json': ['South India'],
        'cuisines_json': ['South Indian', 'Karnataka'],
        'diet_json': ['vegetarian', 'vegan'],
        'tags_json': ['iron', 'calcium', 'fiber'],
        'basis_g': 100.0,
        'energy_kcal': 328.0,
        'protein_g': 7.3,
        'carbohydrate_g': 72.0,
        'fat_g': 1.3,
        'fiber_g': 11.5,
        'iron_mg': 3.9,
        'calcium_mg': 364.0,
      };

      final dto = FoodDto.fromJson(json);
      expect(dto.id, equals('a010_ragi'));
      expect(dto.calciumMg, equals(364.0));

      final domain = FoodMapper.toDomain(dto);
      expect(domain.id, equals('a010_ragi'));
      expect(domain.name, equals('Ragi'));
      expect(domain.tags, contains('iron'));
      expect(domain.calciumMg, equals(364.0));
    });

    test('RecipeDto and RecipeMapper map recipe and ingredients to domain', () {
      final json = {
        'id': 'recipe_ragi_dosa',
        'name': 'Ragi Dosa',
        'cuisine': 'South Indian',
        'servings': 2,
        'prep_time_min': 10,
        'cook_time_min': 15,
        'diet_json': ['vegetarian'],
        'tags_json': ['iron', 'calcium', 'breakfast'],
        'meal_type_json': ['breakfast'],
        'instructions_json': ['Mix batter', 'Pour on hot tava'],
        'nutrition_per_serving': {'energy_kcal': 180.0, 'iron_mg': 2.5},
        'ingredients': [
          {'food_id': 'a010_ragi', 'food_name': 'Ragi Flour', 'quantity': 100.0, 'unit': 'g'},
          {'food_id': 'curd', 'food_name': 'Curd', 'quantity': 50.0, 'unit': 'g'},
        ],
      };

      final dto = RecipeDto.fromJson(json);
      expect(dto.name, equals('Ragi Dosa'));
      expect(dto.ingredients.length, equals(2));

      final domain = RecipeMapper.toDomain(dto);
      expect(domain.id, equals('recipe_ragi_dosa'));
      expect(domain.ingredients.length, equals(2));
      expect(domain.ingredients.first.foodId, equals('a010_ragi'));
    });

    test('RankedRecipeDto maps to RankedRecipeItem', () {
      final json = {
        'recipe_id': 'recipe_ragi_dosa',
        'recipe_name': 'Ragi Dosa',
        'cuisine': 'South Indian',
        'match_percentage': 85.0,
        'matched_count': 3,
        'score': 72.5,
        'missing_ingredients': [
          {'food_id': 'curd', 'food_name': 'Curd', 'quantity': 50.0, 'unit': 'g'}
        ],
        'nutrition_per_serving': {'energy_kcal': 180.0, 'iron_mg': 2.5},
      };

      final dto = RankedRecipeDto.fromJson(json);
      final domain = RecipeMapper.toRankedDomain(dto);
      expect(domain.recipe.id, equals('recipe_ragi_dosa'));
      expect(domain.matchPercentage, equals(85.0));
      expect(domain.missingIngredients.length, equals(1));
    });

    test('CyclePhaseResponseDto maps to CyclePhaseInfo', () {
      final json = {
        'estimated_cycle_day': 8,
        'phase_id': 'follicular',
        'phase_name': 'Follicular Phase',
        'description': 'Vitality and cellular energy.',
        'priority_nutrient_names': ['Protein', 'Folate', 'Zinc'],
        'target_tags': ['protein', 'folate', 'zinc'],
        'nutrition_focus': ['protein', 'folate', 'zinc'],
        'nutrition_context': ['Rising estrogen levels.'],
      };

      final dto = CyclePhaseResponseDto.fromJson(json);
      final domain = CycleMapper.toDomain(dto);
      expect(domain.estimatedCycleDay, equals(8));
      expect(domain.phaseId, equals('follicular'));
      expect(domain.priorityNutrientNames, contains('Protein'));
    });

    test('ShoppingListResponseDto maps to ShoppingListItem domain entities', () {
      final json = {
        'items': [
          {
            'food_id': 'sesame_seeds',
            'food_name': 'Sesame Seeds',
            'quantity': 100.0,
            'unit': 'g',
            'source_recipe_ids': ['recipe_1'],
          }
        ],
        'missing_item_count': 1,
      };

      final dto = ShoppingListResponseDto.fromJson(json);
      expect(dto.items.length, equals(1));

      final domain = ShoppingMapper.toDomain(dto.items.first);
      expect(domain.foodId, equals('sesame_seeds'));
      expect(domain.quantity, equals(100.0));
      expect(domain.isChecked, isFalse);
    });
  });
}
