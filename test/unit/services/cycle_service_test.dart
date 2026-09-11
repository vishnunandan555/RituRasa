import 'package:flutter_test/flutter_test.dart';
import 'package:riturasa/domain/models/cycle.dart';
import 'package:riturasa/domain/services/cycle_service.dart';

void main() {
  const service = CycleService();

  group('CycleService Unit Tests', () {
    test('Calculates Menstrual Phase correctly (Day 1 - 5)', () {
      final periodStart = DateTime(2026, 9, 1);
      final targetDate = DateTime(2026, 9, 3); // Day 3

      final res = service.calculateCycleState(
        lastPeriodStart: periodStart,
        targetDate: targetDate,
        cycleLength: 28,
      );

      expect(res.isOk, isTrue);
      final state = res.valueOrNull!;
      expect(state.currentCycleDay, equals(3));
      expect(state.phaseInfo.phaseType, equals(CyclePhaseType.menstrual));
      expect(state.phaseInfo.priorityNutrientNames, contains('Iron'));
      expect(state.phaseInfo.targetTags, contains('anti_inflammatory'));
      expect(state.daysUntilNextPeriod, equals(26));
    });

    test('Calculates Follicular Phase correctly (Day 6 - 13)', () {
      final periodStart = DateTime(2026, 9, 1);
      final targetDate = DateTime(2026, 9, 9); // Day 9

      final res = service.calculateCycleState(
        lastPeriodStart: periodStart,
        targetDate: targetDate,
        cycleLength: 28,
      );

      expect(res.isOk, isTrue);
      final state = res.valueOrNull!;
      expect(state.currentCycleDay, equals(9));
      expect(state.phaseInfo.phaseType, equals(CyclePhaseType.follicular));
      expect(state.phaseInfo.priorityNutrientNames, contains('Protein'));
      expect(state.phaseInfo.targetTags, contains('zinc'));
    });

    test('Calculates Ovulatory Phase correctly (Day 14 - 16)', () {
      final periodStart = DateTime(2026, 9, 1);
      final targetDate = DateTime(2026, 9, 15); // Day 15

      final res = service.calculateCycleState(
        lastPeriodStart: periodStart,
        targetDate: targetDate,
        cycleLength: 28,
      );

      expect(res.isOk, isTrue);
      final state = res.valueOrNull!;
      expect(state.currentCycleDay, equals(15));
      expect(state.phaseInfo.phaseType, equals(CyclePhaseType.ovulatory));
      expect(state.phaseInfo.targetTags, contains('fiber'));
    });

    test('Calculates Luteal Phase correctly (Day 17 - 28)', () {
      final periodStart = DateTime(2026, 9, 1);
      final targetDate = DateTime(2026, 9, 22); // Day 22

      final res = service.calculateCycleState(
        lastPeriodStart: periodStart,
        targetDate: targetDate,
        cycleLength: 28,
      );

      expect(res.isOk, isTrue);
      final state = res.valueOrNull!;
      expect(state.currentCycleDay, equals(22));
      expect(state.phaseInfo.phaseType, equals(CyclePhaseType.luteal));
      expect(state.phaseInfo.priorityNutrientNames, contains('Magnesium'));
      expect(state.phaseInfo.targetTags, contains('complex_carbs'));
    });

    test('Handles multiple cycle cycles rollover accurately', () {
      final periodStart = DateTime(2026, 7, 1);
      // 56 days = exactly 2 cycles of 28 days
      final targetDate = DateTime(2026, 7, 1).add(const Duration(days: 56)); // Day 1 of 3rd cycle

      final res = service.calculateCycleState(
        lastPeriodStart: periodStart,
        targetDate: targetDate,
        cycleLength: 28,
      );

      expect(res.isOk, isTrue);
      final state = res.valueOrNull!;
      expect(state.currentCycleDay, equals(1));
      expect(state.phaseInfo.phaseType, equals(CyclePhaseType.menstrual));
    });

    test('Returns validation failure on invalid cycle length', () {
      final res = service.calculateCycleState(
        lastPeriodStart: DateTime(2026, 9, 1),
        cycleLength: 10,
      );
      expect(res.isErr, isTrue);
    });
  });
}
