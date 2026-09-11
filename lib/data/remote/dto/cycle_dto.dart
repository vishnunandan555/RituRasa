/// Request DTO for remote cycle phase estimation.
class CycleEstimateRequestDto {
  final String lastPeriodStart; // YYYY-MM-DD
  final int cycleLengthDays;

  const CycleEstimateRequestDto({
    required this.lastPeriodStart,
    this.cycleLengthDays = 28,
  });

  Map<String, dynamic> toJson() {
    return {
      'last_period_start': lastPeriodStart,
      'cycle_length_days': cycleLengthDays,
    };
  }
}

/// Response DTO for cycle phase from SimpleNutriAPI.
class CyclePhaseResponseDto {
  final int estimatedCycleDay;
  final String phaseId;
  final String phaseName;
  final String description;
  final List<String> priorityNutrientNames;
  final List<String> targetTags;
  final List<String> nutritionFocus;
  final List<String> nutritionContext;

  const CyclePhaseResponseDto({
    required this.estimatedCycleDay,
    required this.phaseId,
    required this.phaseName,
    required this.description,
    required this.priorityNutrientNames,
    required this.targetTags,
    required this.nutritionFocus,
    required this.nutritionContext,
  });

  factory CyclePhaseResponseDto.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return CyclePhaseResponseDto(
      estimatedCycleDay: (json['estimated_cycle_day'] as num?)?.toInt() ?? 1,
      phaseId: json['phase_id'] as String? ?? 'follicular',
      phaseName: json['phase_name'] as String? ?? 'Follicular Phase',
      description: json['description'] as String? ?? '',
      priorityNutrientNames: parseList(json['priority_nutrient_names']),
      targetTags: parseList(json['target_tags']),
      nutritionFocus: parseList(json['nutrition_focus']),
      nutritionContext: parseList(json['nutrition_context']),
    );
  }
}
