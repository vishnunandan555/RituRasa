import 'package:equatable/equatable.dart';

/// Supported menstrual cycle phase identifiers.
enum CyclePhaseType {
  menstrual('Period'),
  follicular('Growth'),
  ovulatory('Peak'),
  luteal('Luteal');

  final String displayName;
  const CyclePhaseType(this.displayName);

  static CyclePhaseType fromId(String id) {
    return switch (id.toLowerCase().trim()) {
      'menstrual' || 'period' => CyclePhaseType.menstrual,
      'follicular' || 'growth' => CyclePhaseType.follicular,
      'ovulatory' || 'peak' || 'ovulation' => CyclePhaseType.ovulatory,
      'luteal' => CyclePhaseType.luteal,
      _ => CyclePhaseType.follicular,
    };
  }
}

/// Recorded historical cycle period log.
class CycleRecord extends Equatable {
  final String id;
  final DateTime periodStart;
  final DateTime? periodEnd;
  final int cycleLength;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CycleRecord({
    required this.id,
    required this.periodStart,
    this.periodEnd,
    this.cycleLength = 28,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, periodStart, periodEnd, cycleLength, createdAt, updatedAt];
}

/// Rich cycle phase nutritional guidance and biological priority metadata.
class CyclePhaseInfo extends Equatable {
  final int estimatedCycleDay;
  final String phaseId;
  final String phaseName;
  final String description;
  final List<String> priorityNutrientNames;
  final List<String> targetTags;
  final List<String> nutritionFocus;
  final List<String> nutritionContext;

  const CyclePhaseInfo({
    required this.estimatedCycleDay,
    required this.phaseId,
    required this.phaseName,
    required this.description,
    required this.priorityNutrientNames,
    required this.targetTags,
    required this.nutritionFocus,
    required this.nutritionContext,
  });

  CyclePhaseType get phaseType => CyclePhaseType.fromId(phaseId);

  @override
  List<Object?> get props => [
        estimatedCycleDay,
        phaseId,
        phaseName,
        description,
        priorityNutrientNames,
        targetTags,
        nutritionFocus,
        nutritionContext,
      ];
}

/// High-level current cycle state evaluated locally.
class CycleDayState extends Equatable {
  final int currentCycleDay;
  final CyclePhaseInfo phaseInfo;
  final DateTime phaseStart;
  final DateTime phaseEnd;
  final DateTime estimatedNextPeriod;
  final int daysUntilNextPeriod;
  final double confidenceScore;

  const CycleDayState({
    required this.currentCycleDay,
    required this.phaseInfo,
    required this.phaseStart,
    required this.phaseEnd,
    required this.estimatedNextPeriod,
    required this.daysUntilNextPeriod,
    this.confidenceScore = 1.0,
  });

  @override
  List<Object?> get props => [
        currentCycleDay,
        phaseInfo,
        phaseStart,
        phaseEnd,
        estimatedNextPeriod,
        daysUntilNextPeriod,
        confidenceScore,
      ];
}
