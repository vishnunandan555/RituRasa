import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/domain/models/nutrient_category.dart';

import 'package:riturasa/core/widgets/pressable_scale.dart';

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
    final targetProgress = (category.percentage / 100.0).clamp(0.0, 1.0);

    return PressableScale(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dialWidth = constraints.maxWidth;
          // Responsive dial diameter matching the 3 cards height
          final dialSize = dialWidth.clamp(140.0, 172.0);
          const strokeWidth = 18.0;

          final badgeText = category.percentage < 50
              ? 'Deficit'
              : '+${category.percentage.toInt()}%';

          return SizedBox(
            width: dialSize,
            height: dialSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Circular Progress Track & Arc
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: targetProgress),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedProgress, _) {
                    return CustomPaint(
                      size: Size(dialSize, dialSize),
                      painter: _DialProgressPainter(
                        progress: animatedProgress,
                        activeColor: categoryColor,
                        trackColor: const Color(0xFFF1F5F9),
                        strokeWidth: strokeWidth,
                      ),
                    );
                  },
                ),

                // 2. Center Content with Smooth Cross-fade/Scale Transformation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(category.type),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        // Category Title (e.g. Energy / Weekly cardio)
                        Text(
                          category.title,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Big Percentage (e.g. 49%)
                        Text(
                          '${category.percentage.toInt()}%',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 3),

                        // Subtitle Details (e.g. 1,045 of 2,130)
                        Text(
                          category.details,
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: categoryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Top Pill Badge (e.g. +34 or Deficit)
                Positioned(
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF93C5FD),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(NutrientCategoryType type, RituRasaThemeExtension theme) {
    return switch (type) {
      NutrientCategoryType.energy => const Color(0xFF3B82F6),
      NutrientCategoryType.macro => const Color(0xFF0D9488),
      NutrientCategoryType.vitamins => const Color(0xFF16A34A),
      NutrientCategoryType.minerals => const Color(0xFF9333EA),
    };
  }
}

class _DialProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  _DialProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    this.strokeWidth = 18.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - (strokeWidth / 2) - 2;
    const startAngle = -pi / 2; // 12 o'clock

    // 1. Full 360 background track (soft light grayish-blue)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Active progress arc sweeping counter-clockwise around the left side
    if (progress > 0.0) {
      final sweepAngle = -(2 * pi) * progress.clamp(0.01, 1.0);
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
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
