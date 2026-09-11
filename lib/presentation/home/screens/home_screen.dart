import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
          padding: EdgeInsets.only(
            left: theme.screenPadding,
            right: theme.screenPadding,
            top: 16.0,
            bottom: 110.0, // Avoid overlap with floating pill nav bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 0. App Brand Bar
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.spa_rounded, size: 24),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'RituRasa',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: theme.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'RituRasa',
                          applicationVersion: '1.0.0',
                          applicationIcon: Image.asset('assets/images/logo.png', width: 44, height: 44),
                          applicationLegalese: '© 2026 RituRasa\nAyurvedic Cycle & ICMR-NIN Nutrition Engine.',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Offline Sync',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 180.ms),

              // 1. Date Header
              Text(
                'Today',
                style: theme.dateHeaderStyle,
              ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 4),

              Text(
                dateDisplayString,
                style: theme.dateTitleStyle,
              ).animate().fadeIn(duration: 220.ms, delay: 30.ms).slideY(begin: -0.06, end: 0, curve: Curves.easeOutCubic),

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
              ).animate().fadeIn(duration: 260.ms, delay: 40.ms).scale(begin: const Offset(0.97, 0.97), curve: Curves.easeOutCubic),

              const SizedBox(height: 20),

              // 3. 4-Phase Legend Row
              PhaseLegend(
                activePhase: activePhaseName,
              ).animate().fadeIn(duration: 220.ms, delay: 60.ms),

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

                  SizedBox(width: theme.isCompact ? 8 : 14),

                  // Right Card: Next Period
                  CycleMetricCard(
                    icon: Icon(
                      Icons.water_drop_rounded,
                      size: 20,
                      color: theme.periodColor,
                    ),
                    iconBgColor: theme.nextPeriodIconBg,
                    iconBorder: Border.all(
                      color: const Color(0xFFFFCCD5),
                      width: 2.5,
                    ),
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
                  .fadeIn(duration: 240.ms, delay: 80.ms)
                  .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 24),

              // 5. Nutrient Tracking Policy: Composite Dial & 3 Sub-Cards
              NutritionOverviewSection(
                categories: nutrientCategories,
              )
                  .animate()
                  .fadeIn(duration: 250.ms, delay: 120.ms)
                  .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 20),

              // 7. Standalone Hydration (Water) Card
              const HydrationCard()
                  .animate()
                  .fadeIn(duration: 250.ms, delay: 140.ms)
                  .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),

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
    } else if (day <= 10) {
      return 'Growth';
    } else if (day <= 14) {
      return 'Peak';
    } else {
      return 'Luteal';
    }
  }
}
