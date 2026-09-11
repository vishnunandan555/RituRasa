import '../models/intake_entry.dart';
import '../models/nutrient_totals.dart';

/// Standalone local service calculating daily nutrient intake totals and progress
/// against authoritative ICMR-NIN RDA (Recommended Dietary Allowances) standards.
class NutritionProgressService {
  const NutritionProgressService();

  /// Authoritative ICMR-NIN 2024 RDA reference targets for adult women (19-50 yrs).
  static const Map<String, double> defaultRdaTargets = {
    'energy_kcal': 2130.0,
    'protein_g': 46.0,
    'carbohydrate_g': 130.0,
    'fat_g': 25.0,
    'fiber_g': 30.0,
    'iron_mg': 29.0, // High requirement during reproductive years
    'calcium_mg': 1000.0,
    'magnesium_mg': 370.0,
    'zinc_mg': 13.2,
    'potassium_mg': 3500.0,
    'sodium_mg': 2000.0,
    'vitamin_c_mg': 65.0,
    'folate_ug': 220.0,
    'vitamin_b6_mg': 1.9,
  };

  /// Nutrient display names mapping.
  static const Map<String, (String, String)> nutrientMetadata = {
    'energy_kcal': ('Energy', 'kcal'),
    'protein_g': ('Protein', 'g'),
    'carbohydrate_g': ('Carbohydrates', 'g'),
    'fat_g': ('Fat', 'g'),
    'fiber_g': ('Dietary Fiber', 'g'),
    'iron_mg': ('Iron', 'mg'),
    'calcium_mg': ('Calcium', 'mg'),
    'magnesium_mg': ('Magnesium', 'mg'),
    'zinc_mg': ('Zinc', 'mg'),
    'potassium_mg': ('Potassium', 'mg'),
    'sodium_mg': ('Sodium', 'mg'),
    'vitamin_c_mg': ('Vitamin C', 'mg'),
    'folate_ug': ('Folate (B9)', 'µg'),
    'vitamin_b6_mg': ('Vitamin B6', 'mg'),
  };

  /// Compute aggregated totals and percentage fulfillment for a list of intake entries.
  DailyProgressSummary calculateDailyProgress({
    required String date,
    required List<IntakeEntry> intakes,
    Map<String, double>? customTargets,
  }) {
    final targets = customTargets ?? defaultRdaTargets;
    final Map<String, double> aggregatedTotals = {
      'energy_kcal': 0.0,
      'protein_g': 0.0,
      'carbohydrate_g': 0.0,
      'fat_g': 0.0,
      'fiber_g': 0.0,
      'iron_mg': 0.0,
      'calcium_mg': 0.0,
      'magnesium_mg': 0.0,
      'zinc_mg': 0.0,
      'potassium_mg': 0.0,
      'sodium_mg': 0.0,
      'vitamin_c_mg': 0.0,
      'folate_ug': 0.0,
      'vitamin_b6_mg': 0.0,
    };

    for (final entry in intakes) {
      final consumed = entry.consumedNutrients;
      consumed.forEach((nutrientId, amount) {
        if (aggregatedTotals.containsKey(nutrientId)) {
          aggregatedTotals[nutrientId] = (aggregatedTotals[nutrientId] ?? 0.0) + amount;
        }
      });
    }

    final dailyTotals = DailyNutrientTotals(
      date: date,
      energyKcal: aggregatedTotals['energy_kcal'] ?? 0.0,
      proteinG: aggregatedTotals['protein_g'] ?? 0.0,
      carbG: aggregatedTotals['carbohydrate_g'] ?? 0.0,
      fatG: aggregatedTotals['fat_g'] ?? 0.0,
      fiberG: aggregatedTotals['fiber_g'] ?? 0.0,
      ironMg: aggregatedTotals['iron_mg'] ?? 0.0,
      calciumMg: aggregatedTotals['calcium_mg'] ?? 0.0,
      magnesiumMg: aggregatedTotals['magnesium_mg'] ?? 0.0,
      zincMg: aggregatedTotals['zinc_mg'] ?? 0.0,
      potassiumMg: aggregatedTotals['potassium_mg'] ?? 0.0,
      sodiumMg: aggregatedTotals['sodium_mg'] ?? 0.0,
      vitaminCMg: aggregatedTotals['vitamin_c_mg'] ?? 0.0,
      folateUg: aggregatedTotals['folate_ug'] ?? 0.0,
      vitaminB6Mg: aggregatedTotals['vitamin_b6_mg'] ?? 0.0,
      calculatedAt: DateTime.now(),
    );

    final Map<String, NutrientProgress> progressMap = {};

    aggregatedTotals.forEach((nutrientId, consumedAmount) {
      final target = targets[nutrientId] ?? 1.0;
      final percentage = target > 0 ? (consumedAmount / target) * 100.0 : 0.0;
      final (name, unit) = nutrientMetadata[nutrientId] ?? (nutrientId, '');

      final status = switch (percentage) {
        < 80.0 => NutrientStatus.under,
        >= 80.0 && <= 120.0 => NutrientStatus.optimal,
        _ => NutrientStatus.exceeded,
      };

      progressMap[nutrientId] = NutrientProgress(
        nutrientId: nutrientId,
        nutrientName: name,
        consumed: double.parse(consumedAmount.toStringAsFixed(1)),
        target: target,
        unit: unit,
        percentage: double.parse(percentage.toStringAsFixed(1)),
        status: status,
      );
    });

    return DailyProgressSummary(
      date: date,
      totals: dailyTotals,
      progressMap: progressMap,
    );
  }
}
