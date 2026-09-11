import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';

/// Single horizontal rectangular card presenting the softer anticipated cycle window.
class CycleWindowCard extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  final VoidCallback? onTap;

  const CycleWindowCard({
    super.key,
    required this.currentDay,
    this.totalDays = 28,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final now = DateTime.now();

    final isDuringPeriod = currentDay >= 1 && currentDay <= 5;
    final daysToNextPeriod = (totalDays - currentDay) + 1;

    final String titleText;
    final String pillText;
    final Color pillBg;
    final Color pillTextCol;
    final String dateRangeText;
    final String noteText;
    final IconData cardIcon;

    if (isDuringPeriod) {
      titleText = 'Current Cycle Phase';
      pillText = 'Flow Day $currentDay';
      pillBg = theme.pillNextPeriodBg;
      pillTextCol = theme.pillNextPeriodText;
      final periodStart = now.subtract(Duration(days: currentDay - 1));
      dateRangeText = 'Started on ${DateFormat('MMMM d, yyyy').format(periodStart)}';
      noteText = 'Restorative phase · Emphasize warm fluids, gentle rest & iron nourishment.';
      cardIcon = Icons.water_drop_rounded;
    } else {
      titleText = 'Next Cycle Window';
      pillText = daysToNextPeriod == 1 ? 'Expected tomorrow' : 'in ~$daysToNextPeriod days';
      pillBg = theme.pillNextPeriodBg;
      pillTextCol = theme.pillNextPeriodText;

      final expectedDate = now.add(Duration(days: daysToNextPeriod));
      final windowStart = expectedDate.subtract(const Duration(days: 1));
      final windowEnd = expectedDate.add(const Duration(days: 1));

      if (windowStart.month == windowEnd.month) {
        dateRangeText = '${DateFormat('MMMM d').format(windowStart)} – ${DateFormat('d, yyyy').format(windowEnd)}';
      } else {
        dateRangeText = '${DateFormat('MMM d').format(windowStart)} – ${DateFormat('MMM d, yyyy').format(windowEnd)}';
      }

      noteText = 'Calculated with a natural ±1 day biological window for your cycle rhythm.';
      cardIcon = Icons.spa_rounded;
    }

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: theme.cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: theme.cardShadow,
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Soft Icon + Soft Title + Pill Badge
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.nextPeriodIconBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFCCD5),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    cardIcon,
                    size: 17,
                    color: theme.periodColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titleText,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    pillText,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: pillTextCol,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Middle: Prominent Date Range
            Text(
              dateRangeText,
              style: GoogleFonts.outfit(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),

            // Bottom: Softer Contextual Note
            Text(
              noteText,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: theme.textSecondary.withValues(alpha: 0.85),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
