import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// Daily Nutrition & Biological RDA Progress Screen
/// Shows ICMR-NIN 2024 compliance, macro breakdown,
/// cycle-phase nutrient targets, and daily meal logs.
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    return Scaffold(
      backgroundColor: theme.screenBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: theme.screenPadding,
            right: theme.screenPadding,
            top: 16,
            bottom: 110, // Avoid nav bar overlap
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Daily Nutrition',
                style: theme.screenTitleStyle,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 4),
              Text(
                'ICMR-NIN 2024 RDA & hormonal targets',
                style: theme.screenSubtitleStyle,
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 18),

              // Calorie & Energy Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.cardBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Energy Consumed',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  text: '1,450',
                                  style: GoogleFonts.outfit(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: theme.textPrimary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' / 1,850 kcal',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: theme.growthColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '78% Reached',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.growthColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.78,
                        minHeight: 10,
                        backgroundColor: theme.inactiveTrackColor,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.growthColor),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 18),

              // Macronutrient Progress Grid
              Row(
                children: [
                  _buildMacroTile(context, 'Protein', '52g', '60g', 0.86, const Color(0xFF10B981)),
                  SizedBox(width: theme.isCompact ? 4 : 6),
                  _buildMacroTile(context, 'Carbs', '180g', '240g', 0.75, const Color(0xFFF59E0B)),
                  SizedBox(width: theme.isCompact ? 4 : 6),
                  _buildMacroTile(context, 'Fats', '38g', '50g', 0.76, const Color(0xFF8B5CF6)),
                  SizedBox(width: theme.isCompact ? 4 : 6),
                  _buildMacroTile(context, 'Fiber', '26g', '30g', 0.87, const Color(0xFFFA2C56)),
                ],
              ).animate().fadeIn(duration: 450.ms),

              const SizedBox(height: 24),

              // Critical Phase Micronutrients
              Text(
                'Phase Micronutrient Focus',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildMicroRow(context, 'Bioavailable Iron (Fe)', '18.2 / 21 mg', 0.86, theme.periodColor),
              const SizedBox(height: 10),
              _buildMicroRow(context, 'Zinc (Hormonal Synthesis)', '10.5 / 13 mg', 0.80, theme.growthColor),
              const SizedBox(height: 10),
              _buildMicroRow(context, 'Folate (Cell Division)', '270 / 300 mcg', 0.90, theme.peakColor),
              const SizedBox(height: 10),
              _buildMicroRow(context, 'Magnesium (Relaxation)', '310 / 370 mg', 0.83, const Color(0xFF10B981)),

              const SizedBox(height: 24),

              // Meals Logged Today
              Text(
                'Today\'s Meals',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildMealTile(
                context,
                'Breakfast',
                'Ragi Kanji with Roasted Sesame & Buttermilk',
                '380 kcal • 14g Protein',
                Icons.wb_sunny_outlined,
              ),
              const SizedBox(height: 10),
              _buildMealTile(
                context,
                'Lunch',
                'Methi Brown Rice Khichdi with Ghee & Cucumber Raita',
                '590 kcal • 22g Protein',
                Icons.lunch_dining_outlined,
              ),
              const SizedBox(height: 10),
              _buildMealTile(
                context,
                'Evening Snack',
                'Makhana Roasted in Desi Ghee + Green Moong Sprouts',
                '220 kcal • 9g Protein',
                Icons.coffee_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroTile(
    BuildContext context,
    String label,
    String current,
    String target,
    double progress,
    Color color,
  ) {
    final theme = context.rituTheme;
    final isCompact = theme.isCompact;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 6 : 10,
          vertical: isCompact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: isCompact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                current,
                style: GoogleFonts.outfit(
                  fontSize: isCompact ? 13 : 15,
                  fontWeight: FontWeight.w800,
                  color: theme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: theme.inactiveTrackColor,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroRow(
    BuildContext context,
    String name,
    String amount,
    double progress,
    Color accentColor,
  ) {
    final theme = context.rituTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTile(
    BuildContext context,
    String title,
    String mealName,
    String details,
    IconData icon,
  ) {
    final theme = context.rituTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.cardBorder),
            ),
            child: Icon(icon, color: theme.textPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mealName,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
