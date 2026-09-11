import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';

/// Full-width status card displaying the user's fertility window and current phase badge
/// (e.g. "Fertility Window / High Chance Today" with "🔥 Peak" pill) matching the reference UI mockup.
class FertilityWindowCard extends StatelessWidget {
  final int currentCycleDay;
  final VoidCallback? onTap;

  const FertilityWindowCard({
    super.key,
    required this.currentCycleDay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final (title, subtitle, badgeText, badgeIcon, badgeColor, iconData, iconColor, iconBg, iconBorder) =
        _getInfoForDay(currentCycleDay, theme);

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(22.0),
          border: Border.all(color: theme.cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: theme.cardShadow,
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left circular icon with subtle border
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                border: Border.all(color: iconBorder, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Icon(
                iconData,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right Phase Pill Badge with Flame/Phase Icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.35),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    badgeIcon,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    badgeText,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, String, String, IconData, Color, IconData, Color, Color, Color) _getInfoForDay(
    int day,
    RituRasaThemeExtension theme,
  ) {
    if (day >= 11 && day <= 14) {
      return (
        'Fertility Window',
        'High Chance Today',
        'Peak',
        Icons.local_fire_department_rounded,
        theme.peakColor,
        Icons.auto_awesome,
        theme.peakColor,
        const Color(0xFFF3E8FF),
        const Color(0xFFE9D5FF),
      );
    } else if (day >= 6 && day <= 10) {
      return (
        'Fertile Window',
        'Moderate Chance Today',
        'Fertile',
        Icons.trending_up_rounded,
        theme.growthColor,
        Icons.spa_outlined,
        theme.growthColor,
        const Color(0xFFEFF6FF),
        const Color(0xFFDBEAFE),
      );
    } else if (day <= 5) {
      return (
        'Menstrual Phase',
        'Low Conception Chance',
        'Period',
        Icons.water_drop_rounded,
        theme.periodColor,
        Icons.water_drop_outlined,
        theme.periodColor,
        const Color(0xFFFFF1F2),
        const Color(0xFFFFE4E6),
      );
    } else {
      return (
        'Luteal Phase',
        'Low Conception Chance',
        'Luteal',
        Icons.shield_outlined,
        theme.textSecondary,
        Icons.nightlight_outlined,
        theme.textSecondary,
        const Color(0xFFF3F4F6),
        const Color(0xFFE5E7EB),
      );
    }
  }
}
