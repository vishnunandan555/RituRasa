import 'package:flutter_test/flutter_test.dart';
import 'package:riturasa/domain/models/intake_entry.dart';
import 'package:riturasa/domain/models/nutrient_totals.dart';
import 'package:riturasa/domain/services/nutrition_progress_service.dart';

void main() {
  const service = NutritionProgressService();

  group('NutritionProgressService Unit Tests', () {
    test('Calculates aggregated nutrient intake and progress percentages', () {
      final now = DateTime.now();
      final entries = [
        IntakeEntry(
          id: '1',
          date: '2026-09-11',
          name: 'Ragi Porridge',
          quantity: 2.0, // 2 servings
          unit: 'servings',
          mealType: MealType.breakfast,
          nutrients: const {
            'iron_mg': 3.9,
            'calcium_mg': 364.0,
            'protein_g': 7.3,
            'energy_kcal': 328.0,
          },
          loggedAt: now,
        ),
        IntakeEntry(
          id: '2',
          date: '2026-09-11',
          name: 'Spinach Salad',
          quantity: 1.0,
          unit: 'bowl',
          mealType: MealType.lunch,
          nutrients: const {
            'iron_mg': 2.7,
            'vitamin_c_mg': 28.0,
            'folate_ug': 194.0,
          },
          loggedAt: now,
        ),
      ];

      final summary = service.calculateDailyProgress(
        date: '2026-09-11',
        intakes: entries,
      );

      expect(summary.date, equals('2026-09-11'));
      // Iron: (3.9 * 2) + 2.7 = 7.8 + 2.7 = 10.5 mg
      expect(summary.totals.ironMg, equals(10.5));
      // Calcium: 364 * 2 = 728 mg
      expect(summary.totals.calciumMg, equals(728.0));
      // Protein: 7.3 * 2 = 14.6 g
      expect(summary.totals.proteinG, equals(14.6));

      // Progress percentages against default ICMR targets
      // Calcium target = 1000mg -> 728 / 1000 * 100 = 72.8% -> Under (<80%)
      final calciumProgress = summary.progressMap['calcium_mg']!;
      expect(calciumProgress.percentage, equals(72.8));
      expect(calciumProgress.status, equals(NutrientStatus.under));

      // Folate target = 220µg -> 194 / 220 * 100 = 88.2% -> Optimal (80-120%)
      final folateProgress = summary.progressMap['folate_ug']!;
      expect(folateProgress.percentage, equals(88.2));
      expect(folateProgress.status, equals(NutrientStatus.optimal));
    });

    test('Zero intake produces zero totals with 0% progress', () {
      final summary = service.calculateDailyProgress(
        date: '2026-09-11',
        intakes: [],
      );

      expect(summary.totals.ironMg, equals(0.0));
      expect(summary.progressMap['iron_mg']?.percentage, equals(0.0));
      expect(summary.progressMap['iron_mg']?.status, equals(NutrientStatus.under));
    });
  });
}
