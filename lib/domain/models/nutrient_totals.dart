import 'package:equatable/equatable.dart';

enum NutrientStatus { under, optimal, exceeded }

/// Fulfillment progress for an individual nutrient against RDA target.
class NutrientProgress extends Equatable {
  final String nutrientId;
  final String nutrientName;
  final double consumed;
  final double target;
  final String unit;
  final double percentage; // e.g. 75.5%
  final NutrientStatus status;

  const NutrientProgress({
    required this.nutrientId,
    required this.nutrientName,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.percentage,
    required this.status,
  });

  @override
  List<Object?> get props => [nutrientId, nutrientName, consumed, target, unit, percentage, status];
}

/// Aggregated daily nutrient totals for a given date.
class DailyNutrientTotals extends Equatable {
  final String date;
  final double energyKcal;
  final double proteinG;
  final double carbG;
  final double fatG;
  final double fiberG;
  final double ironMg;
  final double calciumMg;
  final double magnesiumMg;
  final double zincMg;
  final double potassiumMg;
  final double sodiumMg;
  final double vitaminCMg;
  final double folateUg;
  final double vitaminB6Mg;
  final DateTime calculatedAt;

  const DailyNutrientTotals({
    required this.date,
    this.energyKcal = 0.0,
    this.proteinG = 0.0,
    this.carbG = 0.0,
    this.fatG = 0.0,
    this.fiberG = 0.0,
    this.ironMg = 0.0,
    this.calciumMg = 0.0,
    this.magnesiumMg = 0.0,
    this.zincMg = 0.0,
    this.potassiumMg = 0.0,
    this.sodiumMg = 0.0,
    this.vitaminCMg = 0.0,
    this.folateUg = 0.0,
    this.vitaminB6Mg = 0.0,
    required this.calculatedAt,
  });

  Map<String, double> toNutrientMap() {
    return {
      'energy_kcal': energyKcal,
      'protein_g': proteinG,
      'carbohydrate_g': carbG,
      'fat_g': fatG,
      'fiber_g': fiberG,
      'iron_mg': ironMg,
      'calcium_mg': calciumMg,
      'magnesium_mg': magnesiumMg,
      'zinc_mg': zincMg,
      'potassium_mg': potassiumMg,
      'sodium_mg': sodiumMg,
      'vitamin_c_mg': vitaminCMg,
      'folate_ug': folateUg,
      'vitamin_b6_mg': vitaminB6Mg,
    };
  }

  @override
  List<Object?> get props => [
        date,
        energyKcal,
        proteinG,
        carbG,
        fatG,
        fiberG,
        ironMg,
        calciumMg,
        magnesiumMg,
        zincMg,
        potassiumMg,
        sodiumMg,
        vitaminCMg,
        folateUg,
        vitaminB6Mg,
        calculatedAt,
      ];
}

/// Comprehensive daily summary with nutrient totals and progress against RDA targets.
class DailyProgressSummary extends Equatable {
  final String date;
  final DailyNutrientTotals totals;
  final Map<String, NutrientProgress> progressMap;

  const DailyProgressSummary({
    required this.date,
    required this.totals,
    required this.progressMap,
  });

  @override
  List<Object?> get props => [date, totals, progressMap];
}
