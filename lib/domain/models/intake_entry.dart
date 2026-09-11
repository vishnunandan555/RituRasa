import 'package:equatable/equatable.dart';

/// Supported meal categories.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  other;

  static MealType fromString(String val) {
    return MealType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase().trim(),
      orElse: () => MealType.other,
    );
  }
}

/// A logged intake event for food or recipe.
class IntakeEntry extends Equatable {
  final String id;
  final String date; // YYYY-MM-DD
  final String? foodId;
  final String? recipeId;
  final String name;
  final double quantity; // servings or portion multiple
  final String unit;
  final MealType mealType;
  final Map<String, double> nutrients; // nutrient_id -> amount for 1 serving
  final DateTime loggedAt;

  const IntakeEntry({
    required this.id,
    required this.date,
    this.foodId,
    this.recipeId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.mealType,
    required this.nutrients,
    required this.loggedAt,
  });

  /// Computed actual consumed nutrient totals for this intake entry.
  Map<String, double> get consumedNutrients {
    final Map<String, double> result = {};
    nutrients.forEach((k, v) {
      result[k] = v * quantity;
    });
    return result;
  }

  @override
  List<Object?> get props => [
        id,
        date,
        foodId,
        recipeId,
        name,
        quantity,
        unit,
        mealType,
        nutrients,
        loggedAt,
      ];
}
