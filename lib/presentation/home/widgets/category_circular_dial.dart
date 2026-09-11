import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/nutrient_category.dart';

/// Large circular progress dial for the focused / least-filled category
/// matching the exact reference UI layout.
class CategoryCircularDial extends StatelessWidget {
  final NutrientCategoryProgress category;
  final VoidCallback? onTap;

  const CategoryCircularDial({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final categoryColor = _getCategoryColor(category.type, theme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.cardBorder, width: 1.2),
        ),
        child: SizedBox(
          width: 155,
          height: 175,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Circular Progress Track
              CustomPaint(
                size: const Size(140, 140),
                painter: _DialProgressPainter(
                  progress: (category.percentage / 100.0).clamp(0.0, 1.0),
                  activeColor: categoryColor,
                  trackColor: theme.inactiveTrackColor.withValues(alpha: 0.4),
                ),
              ),

              // 2. Center Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Pill Badge (+0 or Focus)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.percentage < 50 ? 'Deficit' : '+${category.percentage.toInt()}%',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Category Title
                  Text(
                    category.title,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Big Percentage
                  Text(
                    '${category.percentage.toInt()}%',
                    style: theme.dialPercentageStyle,
                  ),

                  // Subtitle Details (e.g. 1250 of 2130)
                  Text(
                    category.details,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: categoryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(NutrientCategoryType type, RituRasaThemeExtension theme) {
    return switch (type) {
      NutrientCategoryType.energy => theme.energyCategoryColor,
      NutrientCategoryType.macro => theme.macroCategoryColor,
      NutrientCategoryType.vitamins => theme.vitaminsCategoryColor,
      NutrientCategoryType.minerals => theme.mineralsCategoryColor,
    };
  }
}

class _DialProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color activeColor;
  final Color trackColor;

  _DialProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 8;
    const strokeWidth = 14.0;
    const startAngle = -pi / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (progress > 0.0) {
      final sweepAngle = (2 * pi) * progress;
      final arcPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
