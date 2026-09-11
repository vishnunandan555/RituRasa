import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';
import 'package:riturasa/domain/models/nutrient_category.dart';

/// Horizontal pill sub-card matching the stacked items on the right
/// in the reference screenshot (e.g. Steps 2,532, Readiness 89, Sleep 7h 54m).
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
    final (tintBg, accentColor, icon) = _getStyling(category.type, theme);

    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: tintBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.15), width: 1.0),
        ),
        child: Row(
          children: [
            // Left Rounded Icon Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),

            // Middle: Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.title,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    category.details,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Right: Big Progress Number
            Text(
              '${category.percentage.toInt()}%',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color, IconData) _getStyling(NutrientCategoryType type, RituRasaThemeExtension theme) {
    return switch (type) {
      NutrientCategoryType.energy => (
          theme.energySubCardBg,
          theme.energyCategoryColor,
          Icons.local_fire_department_rounded,
        ),
      NutrientCategoryType.macro => (
          theme.macroSubCardBg,
          theme.macroCategoryColor,
          Icons.egg_alt_rounded,
        ),
      NutrientCategoryType.vitamins => (
          theme.vitaminsSubCardBg,
          theme.vitaminsCategoryColor,
          Icons.spa_rounded,
        ),
      NutrientCategoryType.minerals => (
          theme.mineralsSubCardBg,
          theme.mineralsCategoryColor,
          Icons.diamond_outlined,
        ),
    };
  }
}
