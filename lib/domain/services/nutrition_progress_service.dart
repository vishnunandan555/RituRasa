import 'package:riturasa/domain/models/intake_entry.dart';
import 'package:riturasa/domain/models/nutrient_category.dart';
import 'package:riturasa/domain/models/nutrient_totals.dart';

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

  /// Categorizes nutrients into the 4 primary policy groups:
  /// Energy, Macronutrients, Vitamins, Minerals.
  /// Automatically sorts ascending by fulfillment percentage so that
  /// the least filled category appears first (index 0).
  List<NutrientCategoryProgress> calculateCategoryBreakdown(DailyProgressSummary summary) {
    final map = summary.progressMap;

    // 1. Energy
    final energy = map['energy_kcal'];
    final energyPct = energy?.percentage ?? 0.0;
    final energyProgress = NutrientCategoryProgress(
      type: NutrientCategoryType.energy,
      title: 'Energy',
      percentage: double.parse(energyPct.toStringAsFixed(0)),
      consumed: energy?.consumed ?? 0.0,
      target: energy?.target ?? 2130.0,
      unit: 'kcal',
      details: '${(energy?.consumed ?? 0.0).toInt()} of ${(energy?.target ?? 2130.0).toInt()}',
      itemBreakdown: energy != null ? [energy] : [],
    );

    // 2. Macronutrients
    const macroKeys = ['protein_g', 'carbohydrate_g', 'fat_g', 'fiber_g'];
    final macroItems = macroKeys.map((k) => map[k]).whereType<NutrientProgress>().toList();
    final macroAvg = macroItems.isNotEmpty
        ? macroItems.map((e) => e.percentage).reduce((a, b) => a + b) / macroItems.length
        : 0.0;
    final macroProgress = NutrientCategoryProgress(
      type: NutrientCategoryType.macro,
      title: 'Macronutrients',
      percentage: double.parse(macroAvg.toStringAsFixed(0)),
      consumed: (map['protein_g']?.consumed ?? 0.0) +
          (map['carbohydrate_g']?.consumed ?? 0.0) +
          (map['fat_g']?.consumed ?? 0.0),
      target: 201.0,
      unit: 'g',
      details: '${macroAvg.toInt()} of 100',
      itemBreakdown: macroItems,
    );

    // 3. Vitamins
    const vitaminKeys = ['vitamin_c_mg', 'folate_ug', 'vitamin_b6_mg'];
    final vitaminItems = vitaminKeys.map((k) => map[k]).whereType<NutrientProgress>().toList();
    final vitaminAvg = vitaminItems.isNotEmpty
        ? vitaminItems.map((e) => e.percentage).reduce((a, b) => a + b) / vitaminItems.length
        : 0.0;
    final vitaminProgress = NutrientCategoryProgress(
      type: NutrientCategoryType.vitamins,
      title: 'Vitamins',
      percentage: double.parse(vitaminAvg.toStringAsFixed(0)),
      consumed: vitaminAvg,
      target: 100.0,
      unit: '%',
      details: '${vitaminAvg.toInt()} of 100',
      itemBreakdown: vitaminItems,
    );

    // 4. Minerals
    const mineralKeys = [
      'iron_mg',
      'calcium_mg',
      'magnesium_mg',
      'zinc_mg',
      'potassium_mg',
      'sodium_mg'
    ];
    final mineralItems = mineralKeys.map((k) => map[k]).whereType<NutrientProgress>().toList();
    final mineralAvg = mineralItems.isNotEmpty
        ? mineralItems.map((e) => e.percentage).reduce((a, b) => a + b) / mineralItems.length
        : 0.0;
    final mineralProgress = NutrientCategoryProgress(
      type: NutrientCategoryType.minerals,
      title: 'Minerals',
      percentage: double.parse(mineralAvg.toStringAsFixed(0)),
      consumed: mineralAvg,
      target: 100.0,
      unit: '%',
      details: '${mineralAvg.toInt()} of 100',
      itemBreakdown: mineralItems,
    );

    final list = [energyProgress, macroProgress, vitaminProgress, mineralProgress];
    // Sort ascending by percentage: least filled category will be first at index 0
    list.sort((a, b) => a.percentage.compareTo(b.percentage));
    return list;
  }
}
