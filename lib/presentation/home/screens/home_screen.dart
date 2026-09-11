import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/nutrient_category.dart';
import 'package:riturasa/presentation/home/widgets/cycle_metric_card.dart';
import 'package:riturasa/presentation/home/widgets/cycle_wheel.dart';
import 'package:riturasa/presentation/home/widgets/hydration_card.dart';
import 'package:riturasa/presentation/home/widgets/nutrition_overview_section.dart';
import 'package:riturasa/presentation/home/widgets/phase_legend.dart';

/// RituRasa Home Screen featuring the 28-day circular cycle tracker dial,
/// key physiological phase metrics, dynamic nutrient category dials,
/// and standalone hydration tracking.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Default interactive day initialized to 12 (matching design screenshot)
  int _activeDay = 12;

  List<NutrientCategoryProgress> _buildNutrientCategories() {
    return const [
      NutrientCategoryProgress(
        type: NutrientCategoryType.energy,
        title: 'Energy',
        percentage: 49.0, // Lowest: automatically focused in the large circular dial
        consumed: 1045.0,
        target: 2130.0,
        unit: 'kcal',
        details: '1,045 of 2,130',
      ),
      NutrientCategoryProgress(
        type: NutrientCategoryType.macro,
        title: 'Macronutrients',
        percentage: 78.0,
        consumed: 156.0,
        target: 201.0,
        unit: 'g',
        details: '78 of 100',
      ),
      NutrientCategoryProgress(
        type: NutrientCategoryType.vitamins,
        title: 'Vitamins',
        percentage: 89.0,
        consumed: 89.0,
        target: 100.0,
        unit: '%',
        details: '89 of 100',
      ),
      NutrientCategoryProgress(
        type: NutrientCategoryType.minerals,
        title: 'Minerals',
        percentage: 62.0,
        consumed: 62.0,
        target: 100.0,
        unit: '%',
        details: '62 • Good',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final now = DateTime.now();

    // Formatted date strings
    final weekdayName = DateFormat('EEEE').format(now);
    final monthName = DateFormat('MMMM').format(now);
    final dayNum = now.day;
    final dateDisplayString = '$monthName $dayNum, $weekdayName';

    // Cycle stats
    final totalCycleDays = 28;
    final activePhaseName = _getPhaseNameForDay(_activeDay);

    final daysToOvulation = _activeDay <= 14 ? 14 - _activeDay : (totalCycleDays - _activeDay) + 14;
    final daysToNextPeriod = (totalCycleDays - _activeDay) + 1;
    final nextPeriodDate = now.add(Duration(days: daysToNextPeriod));
    final nextPeriodFormatted = DateFormat('MMMM d, yyyy').format(nextPeriodDate);

    final nutrientCategories = _buildNutrientCategories();

    return Scaffold(
      backgroundColor: theme.screenBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 16.0,
            bottom: 110.0, // Avoid overlap with floating pill nav bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Date Header
              Text(
                'Today',
                style: theme.dateHeaderStyle,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 4),

              Text(
                dateDisplayString,
                style: theme.dateTitleStyle,
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),

              const SizedBox(height: 18),

              // 2. Animated Circular Dial Tracker
              CycleWheel(
                currentCycleDay: _activeDay,
                totalCycleDays: totalCycleDays,
                currentPhaseName: activePhaseName,
                onDaySelected: (day) {
                  setState(() {
                    _activeDay = day;
                  });
                },
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 20),

              // 3. 4-Phase Legend Row
              PhaseLegend(
                activePhase: activePhaseName,
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 24),

              // 4. Metric Cards Row: Ovulation & Next Period
              Row(
                children: [
                  // Left Card: Ovulation
                  CycleMetricCard(
                    icon: Icon(
                      Icons.egg_outlined,
                      size: 20,
                      color: theme.textSecondary,
                    ),
                    iconBgColor: theme.ovulationIconBg,
                    title: 'Ovulation',
                    pillText: 'in $daysToOvulation days',
                    pillBgColor: theme.pillOvulationBg,
                    pillTextColor: theme.pillOvulationText,
                    subtitle: 'Day 14',
                    onTap: () {
                      setState(() {
                        _activeDay = 14;
                      });
                    },
                  ),

                  const SizedBox(width: 14),

                  // Right Card: Next Period
                  CycleMetricCard(
                    icon: Icon(
                      Icons.water_drop_rounded,
                      size: 20,
                      color: theme.periodColor,
                    ),
                    iconBgColor: theme.nextPeriodIconBg,
                    title: 'Next Period',
                    pillText: 'in $daysToNextPeriod days',
                    pillBgColor: theme.pillNextPeriodBg,
                    pillTextColor: theme.pillNextPeriodText,
                    subtitle: nextPeriodFormatted,
                    onTap: () {
                      setState(() {
                        _activeDay = 1;
                      });
                    },
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 350.ms)
                  .slideY(begin: 0.15, end: 0),

              const SizedBox(height: 28),

              // 5. Nutrient Tracking Policy: Composite Dial & 3 Sub-Cards
              NutritionOverviewSection(
                categories: nutrientCategories,
              )
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 450.ms)
                  .slideY(begin: 0.15, end: 0),

              const SizedBox(height: 20),

              // 6. Standalone Hydration (Water) Card
              const HydrationCard()
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 550.ms)
                  .slideY(begin: 0.15, end: 0),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getPhaseNameForDay(int day) {
    if (day <= 5) {
      return 'Period';
    } else if (day <= 11) {
      return 'Growth';
    } else if (day <= 16) {
      return day == 14 ? 'Ovulation' : 'Peak';
    } else {
      return 'Luteal';
    }
  }
}
