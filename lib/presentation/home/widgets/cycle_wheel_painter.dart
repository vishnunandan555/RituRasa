import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/riturasa_theme.dart';

/// CustomPainter drawing the 28-day circular cycle tracker
/// matching the high-fidelity UI design.
class CycleWheelPainter extends CustomPainter {
  final int totalDays;
  final double currentCycleDay; // animated double for smooth transition
  final int activeDay; // exact integer day selected
  final RituRasaThemeExtension theme;
  final double animationProgress;

  CycleWheelPainter({
    this.totalDays = 28,
    required this.currentCycleDay,
    required this.activeDay,
    required this.theme,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 26; // padding for badges and labels

    // Track circumference parameters
    // Day 1 starts at top (approx -pi/2 + slight clockwise offset)
    const startAngle = -pi / 2;
    final sweepPerDay = (2 * pi) / totalDays;

    // 1. Inactive Track Circle
    final trackPaint = Paint()
      ..color = theme.inactiveTrackColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw 28 baseline beads
    for (int day = 1; day <= totalDays; day++) {
      final angle = startAngle + (day - 1) * sweepPerDay;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      // Inactive dot
      final dotPaint = Paint()
        ..color = theme.inactiveTrackColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
    }

    // 3. Draw Active Colored Phase Arcs up to current animated day
    final animatedDay = currentCycleDay * animationProgress;

    for (int day = 1; day <= totalDays; day++) {
      if (day > animatedDay) break;

      final prevAngle = startAngle + (day - 2) * sweepPerDay;
      final currAngle = startAngle + (day - 1) * sweepPerDay;

      final phaseColor = _getColorForDay(day);

      // Draw connecting arc between beads
      if (day > 1) {
        final arcPaint = Paint()
          ..color = phaseColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4.0;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          prevAngle,
          sweepPerDay,
          false,
          arcPaint,
        );
      }

      // Draw filled colored bead
      final x = center.dx + radius * cos(currAngle);
      final y = center.dy + radius * sin(currAngle);

      final beadPaint = Paint()
        ..color = phaseColor
        ..style = PaintingStyle.fill;

      // Special highlight for Day 1: Ring circle
      if (day == 1) {
        final ringPaint = Paint()
          ..color = theme.periodColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        final innerPaint = Paint()
          ..color = theme.screenBackground
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 5.5, innerPaint);
        canvas.drawCircle(Offset(x, y), 5.5, ringPaint);
      } else {
        canvas.drawCircle(Offset(x, y), 4.5, beadPaint);
      }
    }

    // 4. Ovulation Ring Highlight on Day 14
    final day14Angle = startAngle + (14 - 1) * sweepPerDay;
    final day14X = center.dx + radius * cos(day14Angle);
    final day14Y = center.dy + radius * sin(day14Angle);

    final ovulationRingPaint = Paint()
      ..color = theme.ovulationHighlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final ovulationInnerPaint = Paint()
      ..color = theme.screenBackground
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(day14X, day14Y), 7.5, ovulationInnerPaint);
    canvas.drawCircle(Offset(day14X, day14Y), 7.5, ovulationRingPaint);

    // 5. Active Selected Day Badge (Enlarged circle with number, e.g. "12")
    if (activeDay >= 1 && activeDay <= totalDays) {
      final activeAngle = startAngle + (activeDay - 1) * sweepPerDay;
      final activeX = center.dx + radius * cos(activeAngle);
      final activeY = center.dy + radius * sin(activeAngle);

      final activeColor = _getColorForDay(activeDay);

      // Outer soft shadow
      final shadowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(Offset(activeX, activeY), 13.0, shadowPaint);

      // Badge circle
      final badgePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(activeX, activeY), 12.0, badgePaint);

      // Number text inside badge
      final textSpan = TextSpan(
        text: '$activeDay',
        style: TextStyle(
          color: Colors.white,
          fontSize: activeDay > 9 ? 11 : 12,
          fontWeight: FontWeight.w800,
          fontFamily: theme.cycleDayLabelStyle.fontFamily,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(activeX - textPainter.width / 2, activeY - textPainter.height / 2),
      );
    }

    // 6. Cardinal Day Labels outside the ring: 1, 7, 14, 21, 28
    _drawDayLabel(canvas, center, radius + 18, 1, startAngle);
    _drawDayLabel(canvas, center, radius + 18, 7, startAngle + (6 * sweepPerDay));
    _drawDayLabel(canvas, center, radius + 18, 14, startAngle + (13 * sweepPerDay));
    _drawDayLabel(canvas, center, radius + 18, 21, startAngle + (20 * sweepPerDay));
    _drawDayLabel(canvas, center, radius + 18, 28, startAngle + (27 * sweepPerDay));
  }

  void _drawDayLabel(
    Canvas canvas,
    Offset center,
    double labelRadius,
    int dayNumber,
    double angle,
  ) {
    final x = center.dx + labelRadius * cos(angle);
    final y = center.dy + labelRadius * sin(angle);

    final textSpan = TextSpan(
      text: '$dayNumber',
      style: TextStyle(
        color: theme.textSecondary.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        fontFamily: theme.cycleDayLabelStyle.fontFamily,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  Color _getColorForDay(int day) {
    if (day <= 5) {
      return theme.periodColor; // Period
    } else if (day <= 11) {
      return theme.growthColor; // Growth
    } else if (day <= 16) {
      return theme.peakColor; // Peak / Ovulation
    } else {
      return theme.lutealColor; // Luteal
    }
  }

  @override
  bool shouldRepaint(covariant CycleWheelPainter oldDelegate) {
    return oldDelegate.currentCycleDay != currentCycleDay ||
        oldDelegate.activeDay != activeDay ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.theme != theme;
  }
}
