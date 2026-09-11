import 'dart:convert';
import '../../core/utils/result.dart';
import '../../domain/models/intake_entry.dart';
import '../../domain/models/nutrient_totals.dart';
import '../../domain/repositories/i_intake_repository.dart';
import '../local/dao/intake_dao.dart';

class IntakeRepositoryImpl implements IIntakeRepository {
  final IntakeDao intakeDao;

  const IntakeRepositoryImpl(this.intakeDao);

  @override
  Future<Result<void>> logIntake(IntakeEntry entry) async {
    return await intakeDao.logIntake({
      'id': entry.id,
      'date': entry.date,
      'food_id': entry.foodId,
      'recipe_id': entry.recipeId,
      'name': entry.name,
      'quantity': entry.quantity,
      'unit': entry.unit,
      'meal_type': entry.mealType.name,
      'nutrients_json': jsonEncode(entry.nutrients),
      'logged_at': entry.loggedAt.toIso8601String(),
    });
  }

  @override
  Future<Result<List<IntakeEntry>>> getIntakesForDate(String date) async {
    final result = await intakeDao.getIntakesForDate(date);
    return result.map((rows) {
      return rows.map((r) {
        final Map<String, double> nutMap = {};
        try {
          final decoded = jsonDecode(r['nutrients_json']?.toString() ?? '{}');
          if (decoded is Map) {
            decoded.forEach((k, v) {
              if (v is num) nutMap[k.toString()] = v.toDouble();
            });
          }
        } catch (_) {}

        return IntakeEntry(
          id: r['id'] as String,
          date: r['date'] as String,
          foodId: r['food_id'] as String?,
          recipeId: r['recipe_id'] as String?,
          name: r['name'] as String,
          quantity: (r['quantity'] as num).toDouble(),
          unit: r['unit'] as String? ?? 'serving',
          mealType: MealType.fromString(r['meal_type'] as String? ?? 'other'),
          nutrients: nutMap,
          loggedAt: DateTime.tryParse(r['logged_at']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();
    });
  }

  @override
  Future<Result<void>> deleteIntake(String id) async {
    return await intakeDao.deleteIntake(id);
  }

  @override
  Future<Result<DailyNutrientTotals?>> getDailyNutrientTotals(String date) async {
    final result = await intakeDao.getDailyNutrientTotals(date);
    return result.map((row) {
      if (row == null) return null;
      double parseNum(dynamic val) => (val as num?)?.toDouble() ?? 0.0;

      return DailyNutrientTotals(
        date: row['date'] as String,
        energyKcal: parseNum(row['energy_kcal']),
        proteinG: parseNum(row['protein_g']),
        carbG: parseNum(row['carbohydrate_g']),
        fatG: parseNum(row['fat_g']),
        fiberG: parseNum(row['fiber_g']),
        ironMg: parseNum(row['iron_mg']),
        calciumMg: parseNum(row['calcium_mg']),
        magnesiumMg: parseNum(row['magnesium_mg']),
        zincMg: parseNum(row['zinc_mg']),
        potassiumMg: parseNum(row['potassium_mg']),
        sodiumMg: parseNum(row['sodium_mg']),
        vitaminCMg: parseNum(row['vitamin_c_mg']),
        folateUg: parseNum(row['folate_ug']),
        vitaminB6Mg: parseNum(row['vitamin_b6_mg']),
        calculatedAt: DateTime.tryParse(row['calculated_at']?.toString() ?? '') ?? DateTime.now(),
      );
    });
  }

  @override
  Future<Result<void>> saveDailyNutrientTotals(DailyNutrientTotals totals) async {
    return await intakeDao.upsertDailyNutrientTotals({
      'date': totals.date,
      'energy_kcal': totals.energyKcal,
      'protein_g': totals.proteinG,
      'carbohydrate_g': totals.carbG,
      'fat_g': totals.fatG,
      'fiber_g': totals.fiberG,
      'iron_mg': totals.ironMg,
      'calcium_mg': totals.calciumMg,
      'magnesium_mg': totals.magnesiumMg,
      'zinc_mg': totals.zincMg,
      'potassium_mg': totals.potassiumMg,
      'sodium_mg': totals.sodiumMg,
      'vitamin_c_mg': totals.vitaminCMg,
      'folate_ug': totals.folateUg,
      'vitamin_b6_mg': totals.vitaminB6Mg,
      'calculated_at': totals.calculatedAt.toIso8601String(),
    });
  }
}
