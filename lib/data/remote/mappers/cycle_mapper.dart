import '../../../domain/models/cycle.dart';
import '../dto/cycle_dto.dart';

/// Maps CyclePhaseResponseDto to CyclePhaseInfo domain model.
class CycleMapper {
  CycleMapper._();

  static CyclePhaseInfo toDomain(CyclePhaseResponseDto dto) {
    return CyclePhaseInfo(
      estimatedCycleDay: dto.estimatedCycleDay,
      phaseId: dto.phaseId,
      phaseName: dto.phaseName,
      description: dto.description,
      priorityNutrientNames: dto.priorityNutrientNames,
      targetTags: dto.targetTags,
      nutritionFocus: dto.nutritionFocus,
      nutritionContext: dto.nutritionContext,
    );
  }
}
