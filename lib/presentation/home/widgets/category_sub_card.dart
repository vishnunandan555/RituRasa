import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';
import 'package:riturasa/domain/models/nutrient_category.dart';

/// Horizontal pill sub-card matching the stacked items on the right
/// in the reference screenshot (e.g. Steps 3,625, Readiness 85, Sleep 7h 14m / 72 • Good).
class CategorySubCard extends StatelessWidget {
  final NutrientCategoryProgress category;
  final VoidCallback? onTap;

  const CategorySubCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final (bgLight, bgDark, accentColor, icon) = _getStyling(category.type);
    final isCompact = theme.isCompact;
    final progressFraction = (category.percentage / 100.0).clamp(0.22, 1.0);

    return PressableScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: isCompact ? 50 : 54,
          color: bgLight,
          child: Stack(
            children: [
              // 1. Subtle Progress Fill Bar (matching the two-tone card in reference)
              FractionallySizedBox(
                widthFactor: progressFraction,
                alignment: Alignment.centerLeft,
                child: Container(
                  color: bgDark,
                ),
              ),

              // 2. Foreground Content (Icon Badge + Title & Value)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10),
                child: Row(
                  children: [
                    // Left White Circular Icon Badge
                    Container(
                      width: isCompact ? 32 : 36,
                      height: isCompact ? 32 : 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: isCompact ? 17 : 20,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Title & Value Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.title,
                            style: GoogleFonts.outfit(
                              fontSize: isCompact ? 11 : 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor.withValues(alpha: 0.88),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _getValueString(category),
                            style: GoogleFonts.outfit(
                              fontSize: isCompact ? 16 : 18,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getValueString(NutrientCategoryProgress cat) {
    if (cat.type == NutrientCategoryType.minerals && cat.percentage > 50) {
      return '${cat.percentage.toInt()} • Good';
    }
    return '${cat.percentage.toInt()}%';
  }

  (Color, Color, Color, IconData) _getStyling(NutrientCategoryType type) {
    return switch (type) {
      NutrientCategoryType.energy => (
          const Color(0xFFDBEAFE), // Light blue
          const Color(0xFF93C5FD), // Mid blue
          const Color(0xFF1D4ED8), // Deep blue
          Icons.local_fire_department_rounded,
        ),
      NutrientCategoryType.macro => (
          const Color(0xFFCCFBF1), // Light teal
          const Color(0xFF5EEAD4), // Mid teal
          const Color(0xFF0F766E), // Deep teal
          Icons.egg_alt_rounded,
        ),
      NutrientCategoryType.vitamins => (
          const Color(0xFFDCFCE7), // Light green
          const Color(0xFF86EFAC), // Mid green
          const Color(0xFF166534), // Deep green
          Icons.spa_rounded,
        ),
      NutrientCategoryType.minerals => (
          const Color(0xFFF3E8FF), // Light purple
          const Color(0xFFD8B4FE), // Mid purple
          const Color(0xFF6B21A8), // Deep purple
          Icons.diamond_outlined,
        ),
    };
  }
}
