import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../models/cycle.dart';

/// Standalone, 100% offline menstrual cycle calculation service.
/// Authoritative for cycle day, active physiological phase, and next period estimation.
class CycleService {
  const CycleService();

  /// Calculate the current cycle state given a period start date and target date.
  Result<CycleDayState> calculateCycleState({
    required DateTime lastPeriodStart,
    DateTime? targetDate,
    int cycleLength = 28,
  }) {
    try {
      if (cycleLength < 20 || cycleLength > 45) {
        return const Result.err(ValidationFailure(
          message: 'Cycle length must be between 20 and 45 days.',
        ));
      }

      final date = targetDate ?? DateTime.now();
      // Normalize dates to start of day (midnight) to avoid timezone/hour skew
      final startMidnight = DateTime(lastPeriodStart.year, lastPeriodStart.month, lastPeriodStart.day);
      final targetMidnight = DateTime(date.year, date.month, date.day);

      final diffDays = targetMidnight.difference(startMidnight).inDays;
      if (diffDays < 0) {
        return const Result.err(CycleCalculationFailure(
          message: 'Target date cannot precede the last period start date.',
        ));
      }

      final currentCycleDay = (diffDays % cycleLength) + 1;
      final phaseInfo = getPhaseInfoForDay(currentCycleDay, cycleLength: cycleLength);

      final currentCycleIndex = diffDays ~/ cycleLength;
      final currentCycleStartDate = startMidnight.add(Duration(days: currentCycleIndex * cycleLength));
      final estimatedNextPeriod = currentCycleStartDate.add(Duration(days: cycleLength));
      final daysUntilNextPeriod = estimatedNextPeriod.difference(targetMidnight).inDays;

      final (phaseStartOffset, phaseEndOffset) = _getPhaseOffsets(phaseInfo.phaseType, cycleLength);
      final phaseStart = currentCycleStartDate.add(Duration(days: phaseStartOffset - 1));
      final phaseEnd = currentCycleStartDate.add(Duration(days: phaseEndOffset - 1));

      return Result.ok(CycleDayState(
        currentCycleDay: currentCycleDay,
        phaseInfo: phaseInfo,
        phaseStart: phaseStart,
        phaseEnd: phaseEnd,
        estimatedNextPeriod: estimatedNextPeriod,
        daysUntilNextPeriod: daysUntilNextPeriod,
        confidenceScore: 1.0,
      ));
    } catch (e) {
      return Result.err(CycleCalculationFailure(
        message: 'Failed to calculate cycle state: $e',
        cause: e,
      ));
    }
  }

  /// Get Phase Info metadata corresponding to a specific cycle day.
  CyclePhaseInfo getPhaseInfoForDay(int cycleDay, {int cycleLength = 28}) {
    if (cycleDay <= 5) {
      return CyclePhaseInfo(
        estimatedCycleDay: cycleDay,
        phaseId: 'menstrual',
        phaseName: 'Menstrual Phase',
        description: 'Replenish iron stores and soothe uterine muscle contractions with gentle minerals and hydration.',
        priorityNutrientNames: const ['Iron', 'Vitamin C', 'Magnesium'],
        targetTags: const ['iron', 'vitamin_c', 'magnesium', 'anti_inflammatory'],
        nutritionFocus: const ['iron', 'vitamin_c', 'protein', 'folate'],
        nutritionContext: const [
          'Menstrual blood loss increases biological iron demand.',
          'Vitamin C markedly improves absorption of non-heme iron from pulses and millets.',
          'Magnesium supports smooth muscle relaxation and eases uterine cramping.',
          'Adequate hydration and light, easily digestible meals maintain steady digestion.',
        ],
      );
    } else if (cycleDay <= (cycleLength > 30 ? 14 : 13)) {
      return CyclePhaseInfo(
        estimatedCycleDay: cycleDay,
        phaseId: 'follicular',
        phaseName: 'Follicular Phase',
        description: 'Support rising estrogen and cellular energy with clean protein, B-vitamins, and zinc.',
        priorityNutrientNames: const ['Protein', 'Folate (B9)', 'Zinc'],
        targetTags: const ['protein', 'folate', 'zinc'],
        nutritionFocus: const ['protein', 'folate', 'zinc', 'vitamin_b6'],
        nutritionContext: const [
          'Rising follicular activity benefits from steady dietary amino acids and protein.',
          'Folate and zinc support normal cell division and metabolic vitality.',
          'Complex carbohydrates from whole grains and millets provide sustained endurance.',
        ],
      );
    } else if (cycleDay <= (cycleLength > 30 ? 17 : 16)) {
      return CyclePhaseInfo(
        estimatedCycleDay: cycleDay,
        phaseId: 'ovulatory',
        phaseName: 'Ovulatory Phase',
        description: 'Prioritize antioxidant-rich whole foods, dietary fiber, and adequate hydration during peak estrogen.',
        priorityNutrientNames: const ['Dietary Fiber', 'Zinc', 'Antioxidants'],
        targetTags: const ['fiber', 'zinc', 'antioxidant'],
        nutritionFocus: const ['fiber', 'zinc', 'antioxidant', 'potassium'],
        nutritionContext: const [
          'Estrogen peaks; dietary fiber assists normal hepatic hormone clearance.',
          'Zinc and antioxidant-dense vegetables support cellular integrity.',
          'Hydrating foods and leafy greens promote optimal electrolyte balance.',
        ],
      );
    } else {
      return CyclePhaseInfo(
        estimatedCycleDay: cycleDay,
        phaseId: 'luteal',
        phaseName: 'Luteal Phase',
        description: 'Support steady mood and stamina with magnesium, calcium, and complex slow-release carbohydrates.',
        priorityNutrientNames: const ['Magnesium', 'Calcium', 'Vitamin B6', 'Complex Carbs'],
        targetTags: const ['magnesium', 'calcium', 'vitamin_b6', 'complex_carbs', 'pms_support'],
        nutritionFocus: const ['magnesium', 'calcium', 'vitamin_b6', 'complex_carbs'],
        nutritionContext: const [
          'Progesterone elevates basal metabolic rate, favoring unrefined complex carbohydrates.',
          'Magnesium and calcium dietary intake soothe neuromuscular excitability.',
          'Vitamin B6 acts as an essential cofactor in serotonin and dopamine synthesis.',
        ],
      );
    }
  }

  (int, int) _getPhaseOffsets(CyclePhaseType phase, int cycleLength) {
    return switch (phase) {
      CyclePhaseType.menstrual => (1, 5),
      CyclePhaseType.follicular => (6, cycleLength > 30 ? 14 : 13),
      CyclePhaseType.ovulatory => (cycleLength > 30 ? 15 : 14, cycleLength > 30 ? 17 : 16),
      CyclePhaseType.luteal => (cycleLength > 30 ? 18 : 17, cycleLength),
    };
  }
}
