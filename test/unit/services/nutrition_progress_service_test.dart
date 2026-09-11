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

    test('calculateCategoryBreakdown groups 4 categories and sorts least filled first', () {
      final now = DateTime.now();
      final entries = [
        IntakeEntry(
          id: '1',
          date: '2026-09-11',
          name: 'Ragi Porridge',
          quantity: 1.0,
          unit: 'serving',
          mealType: MealType.breakfast,
          nutrients: const {
            'energy_kcal': 300.0, // ~14% of 2130 kcal -> lowest!
            'protein_g': 25.0,    // ~54% of 46g
            'carbohydrate_g': 140.0, // ~50% of 280g
            'fat_g': 25.0,        // ~50% of 50g
            'iron_mg': 20.0,      // ~69% of 29mg
            'calcium_mg': 700.0,  // 70% of 1000mg
            'magnesium_mg': 260.0,// 70% of 370mg
            'zinc_mg': 9.2,       // ~70% of 13.2mg
            'potassium_mg': 2450.0, // 70% of 3500mg
            'sodium_mg': 1400.0,  // 70% of 2000mg
            'vitamin_c_mg': 50.0, // ~77% of 65mg
            'folate_ug': 180.0,   // ~82% of 220ug
            'vitamin_b6_mg': 1.5, // ~79% of 1.9mg
          },
          loggedAt: now,
        ),
      ];

      final summary = service.calculateDailyProgress(
        date: '2026-09-11',
        intakes: entries,
      );

      final categories = service.calculateCategoryBreakdown(summary);

      expect(categories.length, equals(4));
      // Energy has lowest percentage (14%), so it must be first at index 0!
      expect(categories.first.title, equals('Energy'));
      expect(categories.first.percentage, lessThan(categories[1].percentage));
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
