import 'package:equatable/equatable.dart';
import 'package:riturasa/domain/models/nutrient_totals.dart';

/// The 4 main nutrient categories tracking policy.
enum NutrientCategoryType {
  energy,
  macro,
  vitamins,
  minerals,
}

/// Aggregated fulfillment progress for a primary nutrition category.
class NutrientCategoryProgress extends Equatable {
  final NutrientCategoryType type;
  final String title;
  final double percentage; // e.g. 49.0%
  final double consumed;
  final double target;
  final String unit;
  final String details; // e.g. "1,250 of 2,130 kcal"
  final List<NutrientProgress> itemBreakdown;

  const NutrientCategoryProgress({
    required this.type,
    required this.title,
    required this.percentage,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.details,
    this.itemBreakdown = const [],
  });

  @override
  List<Object?> get props => [type, title, percentage, consumed, target, unit, details, itemBreakdown];
}
