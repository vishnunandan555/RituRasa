import 'dart:math';
import 'package:flutter/material.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// CustomPainter drawing the 28-day circular cycle tracker.
/// Uses a continuous sweep gradient arc and multi-pass bead rendering
/// to completely eliminate color overlapping and visual bleeding between phases.
class CycleWheelPainter extends CustomPainter {
  final int totalDays;
  final double currentCycleDay; // animated double for smooth transition
  final int activeDay; // exact integer day selected
  final RituRasaThemeExtension theme;
  final double animationProgress;
  final double pulseProgress; // 0.0 to 1.0 breathing pulse animation

  CycleWheelPainter({
    this.totalDays = 28,
    required this.currentCycleDay,
    required this.activeDay,
    required this.theme,
    required this.animationProgress,
    this.pulseProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 26; // padding for badges and labels

    // Track starts at top (12 o'clock = -pi / 2)
    const startAngle = -pi / 2;
    final sweepPerDay = (2 * pi) / totalDays;
    final dialRect = Rect.fromCircle(center: center, radius: radius);

    // =========================================================================
    // PASS 1: Draw Inactive Base Track & Inactive Beads
    // =========================================================================
    final trackPaint = Paint()
      ..color = theme.inactiveTrackColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, trackPaint);

    for (int day = 1; day <= totalDays; day++) {
      final angle = startAngle + (day - 1) * sweepPerDay;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      final dotPaint = Paint()
        ..color = theme.inactiveTrackColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
    }

    // =========================================================================
    // PASS 2: Draw Continuous Gradient Arc (Zero Overlapping Caps)
    // =========================================================================
    final effectiveDay = currentCycleDay * animationProgress;

    if (effectiveDay > 1.0) {
      // Calculate active sweep angle from Day 1 to effectiveDay
      final activeSweep = ((effectiveDay - 1.0) / totalDays) * (2 * pi);

      // Gradient stops mapped across the 28-day cycle:
      // - Days 1 to 5: Period (solid coral-red)
      // - Days 5 to 6: Smooth micro-blend to Growth (blue)
      // - Days 6 to 11: Growth (solid blue)
      // - Days 11 to 12: Smooth micro-blend to Peak (purple)
      // - Days 12 to 16: Peak (solid purple)
      // - Days 16 to 17: Smooth micro-blend to Luteal (neutral slate)
      // - Days 17 to 28: Luteal (neutral slate)
      // Gradient stops mapped across the 28-day cycle matching the mockup:
      // - Days 1 to 5: Period (solid crimson)
      // - Days 5 to 6: Micro-blend to Fertile (blue)
      // - Days 6 to 10: Fertile (solid blue)
      // - Days 10 to 11: Micro-blend to Peak (purple)
      // - Days 11 to 13: Peak (solid purple)
      // - Days 13 to 14: Micro-blend to Ovulation (emerald mint)
      // - Days 14 to 15: Micro-blend to Luteal (neutral slate)
      // - Days 15 to 28: Luteal (neutral slate)
      final sweepGradient = SweepGradient(
        center: Alignment.center,
        startAngle: startAngle,
        endAngle: startAngle + (2 * pi),
        colors: [
          theme.periodColor,             // Day 1
          theme.periodColor,             // Day 5
          theme.growthColor,             // Day 6
          theme.growthColor,             // Day 10
          theme.peakColor,               // Day 11
          theme.peakColor,               // Day 13
          theme.ovulationHighlightColor, // Day 14
          theme.lutealColor,             // Day 15
          theme.lutealColor,             // Day 28
        ],
        stops: const [
          0.0,            // Day 1
          4.0 / 28.0,     // Day 5
          5.0 / 28.0,     // Day 6
          9.0 / 28.0,     // Day 10
          10.0 / 28.0,    // Day 11
          12.0 / 28.0,    // Day 13
          13.0 / 28.0,    // Day 14
          14.0 / 28.0,    // Day 15
          1.0,            // Day 28
        ],
      );

      final arcPaint = Paint()
        ..shader = sweepGradient.createShader(dialRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        dialRect,
        startAngle,
        activeSweep,
        false,
        arcPaint,
      );
    }

    // =========================================================================
    // PASS 3: Draw Active Colored Beads On Top (Pristine, Crisp Edges)
    // =========================================================================
    final animatedDayInt = effectiveDay.floor();

    for (int day = 1; day <= totalDays; day++) {
      if (day > animatedDayInt && day != activeDay) continue;

      final angle = startAngle + (day - 1) * sweepPerDay;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      final phaseColor = _getColorForDay(day);

      // Special highlight for Day 1: Ring circle (Period start)
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
      } else if (day != activeDay && day != 14) {
        // Active bead with subtle clean white halo to separate crisply from background
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        final beadPaint = Paint()
          ..color = phaseColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 4.2, beadPaint);
        canvas.drawCircle(Offset(x, y), 4.2, borderPaint);
      }
    }

    // =========================================================================
    // PASS 4: Ovulation Ring Highlight on Day 14 (With Subtle Breathing Pulse)
    // =========================================================================
    final day14Angle = startAngle + (14 - 1) * sweepPerDay;
    final day14X = center.dx + radius * cos(day14Angle);
    final day14Y = center.dy + radius * sin(day14Angle);

    final ovulationPulseScale = 1.0 + (0.08 * pulseProgress);
    final ovulationRadius = 7.5 * ovulationPulseScale;

    // Outer soft glow
    final ovulationGlowPaint = Paint()
      ..color = theme.ovulationHighlightColor.withValues(alpha: 0.25 + 0.15 * pulseProgress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawCircle(Offset(day14X, day14Y), ovulationRadius + 2.0, ovulationGlowPaint);

    final ovulationInnerPaint = Paint()
      ..color = theme.screenBackground
      ..style = PaintingStyle.fill;

    final ovulationRingPaint = Paint()
      ..color = theme.ovulationHighlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(Offset(day14X, day14Y), ovulationRadius, ovulationInnerPaint);
    canvas.drawCircle(Offset(day14X, day14Y), ovulationRadius, ovulationRingPaint);

    // =========================================================================
    // PASS 5: Active Selected Day Badge (Floating Pill with Smooth Breathing Glow)
    // =========================================================================
    if (activeDay >= 1 && activeDay <= totalDays) {
      final activeAngle = startAngle + (activeDay - 1) * sweepPerDay;
      final activeX = center.dx + radius * cos(activeAngle);
      final activeY = center.dy + radius * sin(activeAngle);

      final activeColor = _getColorForDay(activeDay);
      final badgeScale = 1.0 + (0.06 * pulseProgress);
      final badgeRadius = 12.5 * badgeScale;

      // Soft colored ambient shadow
      final shadowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.35 + (0.15 * pulseProgress))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(Offset(activeX, activeY), badgeRadius + 3.0, shadowPaint);

      // Badge solid background
      final badgePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(activeX, activeY), badgeRadius, badgePaint);

      // Subtle crisp white rim
      final badgeRimPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(Offset(activeX, activeY), badgeRadius, badgeRimPaint);

      // Number text inside badge
      final textSpan = TextSpan(
        text: '$activeDay',
        style: TextStyle(
          color: Colors.white,
          fontSize: activeDay > 9 ? 11.5 : 12.5,
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

    // =========================================================================
    // PASS 6: Cardinal Day Markers (1, 7, 14, 21, 28)
    // =========================================================================
    _drawDayLabel(canvas, center, radius + 19, 1, startAngle);
    _drawDayLabel(canvas, center, radius + 19, 7, startAngle + (6 * sweepPerDay));
    _drawDayLabel(canvas, center, radius + 19, 14, startAngle + (13 * sweepPerDay));
    _drawDayLabel(canvas, center, radius + 19, 21, startAngle + (20 * sweepPerDay));
    _drawDayLabel(canvas, center, radius + 19, 28, startAngle + (27 * sweepPerDay));
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
      return theme.periodColor; // Period (Days 1 - 5)
    } else if (day <= 10) {
      return theme.growthColor; // Fertile / Growth (Days 6 - 10)
    } else if (day <= 13) {
      return theme.peakColor; // Peak (Days 11 - 13)
    } else if (day == 14) {
      return theme.ovulationHighlightColor; // Ovulation (Day 14)
    } else {
      return theme.lutealColor; // Luteal (Days 15 - 28)
    }
  }

  @override
  bool shouldRepaint(covariant CycleWheelPainter oldDelegate) {
    return oldDelegate.currentCycleDay != currentCycleDay ||
        oldDelegate.activeDay != activeDay ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.theme != theme;
  }
}
