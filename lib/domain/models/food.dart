import 'package:equatable/equatable.dart';

/// Represents a specific nutrient value and its unit.
class NutrientAmount extends Equatable {
  final String nutrientId;
  final String name;
  final double amount;
  final String unit;
  final double basisG;

  const NutrientAmount({
    required this.nutrientId,
    required this.name,
    required this.amount,
    required this.unit,
    this.basisG = 100.0,
  });

  @override
  List<Object?> get props => [nutrientId, name, amount, unit, basisG];
}

/// Pure domain representation of a food item.
class FoodItem extends Equatable {
  final String id;
  final String? code;
  final String name;
  final String? scientificName;
  final String category;
  final List<String> aliases;
  final List<String> regions;
  final List<String> cuisines;
  final List<String> diet;
  final List<String> tags;
  final double basisG;
  final double? energyKcal;
  final double? proteinG;
  final double? carbohydrateG;
  final double? fatG;
  final double? fiberG;
  final double? ironMg;
  final double? calciumMg;
  final double? magnesiumMg;
  final double? zincMg;
  final double? potassiumMg;
  final double? sodiumMg;
  final double? folateUg;
  final double? vitaminCMg;
  final double? vitaminB6Mg;

  const FoodItem({
    required this.id,
    this.code,
    required this.name,
    this.scientificName,
    required this.category,
    this.aliases = const [],
    this.regions = const [],
    this.cuisines = const [],
    this.diet = const [],
    this.tags = const [],
    this.basisG = 100.0,
    this.energyKcal,
    this.proteinG,
    this.carbohydrateG,
    this.fatG,
    this.fiberG,
    this.ironMg,
    this.calciumMg,
    this.magnesiumMg,
    this.zincMg,
    this.potassiumMg,
    this.sodiumMg,
    this.folateUg,
    this.vitaminCMg,
    this.vitaminB6Mg,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        scientificName,
        category,
        aliases,
        regions,
        cuisines,
        diet,
        tags,
        basisG,
        energyKcal,
        proteinG,
        carbohydrateG,
        fatG,
        fiberG,
        ironMg,
        calciumMg,
        magnesiumMg,
        zincMg,
        potassiumMg,
        sodiumMg,
        folateUg,
        vitaminCMg,
        vitaminB6Mg,
      ];
}
