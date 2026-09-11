import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/nutrient_category.dart';
import 'package:riturasa/presentation/eat/widgets/recipe_detail_sheet.dart';
import 'package:riturasa/presentation/home/widgets/cycle_metric_card.dart';
import 'package:riturasa/presentation/home/widgets/cycle_wheel.dart';
import 'package:riturasa/presentation/home/widgets/hydration_card.dart';
import 'package:riturasa/presentation/home/widgets/nutrition_overview_section.dart';
import 'package:riturasa/presentation/home/widgets/phase_legend.dart';
import 'package:riturasa/presentation/navigation/screens/main_shell_screen.dart';

/// RituRasa Home Screen featuring the 28-day circular cycle tracker dial,
/// key physiological phase metrics, dynamic nutrient category dials,
/// contextual daily nutrition focus, suggested next meal, and standalone hydration tracking.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Default interactive day initialized to 12 (Peak/Ovulatory window)
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

  Map<String, String> _getNutritionFocusForPhase(String phase) {
    switch (phase) {
      case 'Period':
        return {
          'title': 'Iron · Vitamin C · Hydration',
          'body': 'Focus on bioavailable iron from leafy greens and lentils, paired with vitamin C to maximize absorption and support blood replenishment.',
        };
      case 'Growth':
        return {
          'title': 'Protein · Healthy Fats · B-Vitamins',
          'body': 'Support follicular development and estrogen building with light dals, sprouted seeds, and energizing B-vitamins.',
        };
      case 'Peak':
        return {
          'title': 'Zinc · Fiber · Antioxidants',
          'body': 'Support ovulation and hepatic estrogen metabolism with zinc-rich seeds (pumpkin/sesame) and high-fiber seasonal vegetables.',
        };
      case 'Luteal':
      default:
        return {
          'title': 'Magnesium · Vitamin B6 · Complex Carbs',
          'body': 'Support progesterone production, prevent PMS cravings, and promote nervous system calm with warm cooked meals and magnesium-rich foods.',
        };
    }
  }

  void _openSuggestedMeal() {
    RecipeDetailSheet.show(
      context,
      recipe: {
        'name': 'Spinach Moong Dal',
        'hindi': 'पालक मूंग दाल',
        'region': 'North/South Indian',
        'mealType': 'Lunch / Dinner',
        'time': '25 mins',
        'servings': '2 servings',
        'match': '94% Kitchen Match',
        'badge': 'Highest Match',
        'why': 'Rich in non-heme bioavailable iron and easily digestible moong dal protein. Paired with cumin and turmeric to support digestion and hormone balance.',
        'calories': '280 kcal',
        'protein': '16g',
        'iron': '4.8 mg',
        'calcium': '140 mg',
        'fiber': '8g',
        'ingredients': [
          {'name': 'Fresh Palak (Spinach)', 'qty': '2 bunches', 'inKitchen': true},
          {'name': 'Yellow Moong Dal (Split)', 'qty': '1 cup (150g)', 'inKitchen': true},
          {'name': 'Turmeric (Haldi)', 'qty': '1/2 tsp', 'inKitchen': true},
          {'name': 'Jeera (Cumin Seeds)', 'qty': '1 tsp', 'inKitchen': true},
          {'name': 'Desi Ghee / Sesame Oil', 'qty': '1 tbsp', 'inKitchen': true},
          {'name': 'Fresh Lemon Juice', 'qty': '1 tbsp', 'inKitchen': false},
        ],
        'steps': [
          'Wash yellow moong dal thoroughly and pressure cook with 3 cups of water and turmeric for 3 whistles.',
          'In a kadai, warm 1 tbsp desi ghee. Add cumin seeds and let them splutter gently.',
          'Add chopped spinach and sauté for 3-4 minutes until wilted and vibrant green.',
          'Pour in the cooked dal, season with pink salt, and simmer for 5-7 minutes.',
          'Turn off flame and squeeze fresh lemon juice to maximize iron bioavailability.',
        ],
      },
    );
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
    final nutritionFocus = _getNutritionFocusForPhase(activePhaseName);

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
                          applicationLegalese: '© 2026 RituRasa\nAyurvedic Cycle & Nutrition Engine.',
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

              const SizedBox(height: 20),

              // 4b. Suggested Next Meal Card (SRS requirement)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.navBarActivePill.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.restaurant_rounded, color: theme.navBarActivePill, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'What should you eat next?',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '94% Match',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Spinach Moong Dal',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: theme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rich in iron and light plant protein for $activePhaseName phase.',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: theme.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _openSuggestedMeal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.navBarActivePill,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'View Meal',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms, delay: 90.ms),

              const SizedBox(height: 20),

              // 4c. Today's Nutrition Focus Card (SRS requirement)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bolt_rounded, color: Color(0xFF8B5CF6), size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Today's Nutrition Focus ($activePhaseName Phase)",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nutritionFocus['title']!,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nutritionFocus['body']!,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: theme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms, delay: 100.ms),

              const SizedBox(height: 20),

              // 4d. Quick Actions Row (Eat, Log Meal, Kitchen, Cart)
              Row(
                children: [
                  _buildQuickActionBtn(
                    theme,
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Eat',
                    onTap: () => MainShellScope.of(context)?.switchTab(0),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionBtn(
                    theme,
                    icon: Icons.edit_note_rounded,
                    label: 'Log Food',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Quick Food Logging: Choose a recipe or mark meal in Eat tab.',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                          ),
                          backgroundColor: const Color(0xFF1E293B),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionBtn(
                    theme,
                    icon: Icons.kitchen_rounded,
                    label: 'Kitchen',
                    onTap: () => MainShellScope.of(context)?.switchTab(1),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionBtn(
                    theme,
                    icon: Icons.shopping_bag_outlined,
                    label: 'Cart',
                    onTap: () => MainShellScope.of(context)?.switchTab(3),
                  ),
                ],
              ).animate().fadeIn(duration: 250.ms, delay: 110.ms),

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

  Widget _buildQuickActionBtn(
    RituRasaThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: theme.navBarActivePill),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
              ),
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
