import 'dart:math';
import 'package:flutter/material.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// CustomPainter drawing the 28-day circular cycle tracker.
///
/// Matches the reference design:
/// - Full circle of small light-gray inactive dot beads.
/// - Solid per-phase colored arc strokes connecting the active days.
/// - Phase-colored filled beads sit on top of the arc strokes.
/// - Day 1 as a hollow pink ring. Day 14 as a hollow teal ring + "OVULATION" label.
/// - Active selected day as a large filled badge with the day number.
/// - Breathing pulse animation on the active badge and ovulation ring.
/// - Cardinal day labels (1, 7, 14, 21, 28) outside the ring.
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

  // Phase boundary days (inclusive end)
  static const _phaseBoundaries = [
    (start: 1, end: 5),   // Period
    (start: 6, end: 10),  // Fertile
    (start: 11, end: 13), // Peak
    (start: 14, end: 14), // Ovulation
    (start: 15, end: 28), // Luteal
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 26;

    const startAngle = -pi / 2;
    final sweepPerDay = (2 * pi) / totalDays;

    // Effective animated day progress (clamped)
    final effectiveDay = (currentCycleDay * animationProgress).clamp(1.0, totalDays.toDouble());

    // =========================================================================
    // PASS 1: Thin base circle track (light gray)
    // =========================================================================
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = theme.inactiveTrackColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // =========================================================================
    // PASS 2: All inactive gray beads (every day position)
    // =========================================================================
    for (int day = 1; day <= totalDays; day++) {
      final angle = startAngle + (day - 1) * sweepPerDay;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(
        Offset(x, y),
        3.2,
        Paint()
          ..color = theme.inactiveTrackColor
          ..style = PaintingStyle.fill,
      );
    }

    // =========================================================================
    // PASS 3: Per-phase solid colored arc strokes (the connecting lines)
    // Draw one arc per phase, clipped to effectiveDay
    // =========================================================================
    final dialRect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (final phase in _phaseBoundaries) {
      if (phase.start > effectiveDay) break;

      final phaseColor = _getColorForDay(phase.start);
      final phaseEnd = phase.end.toDouble().clamp(1.0, effectiveDay);

      // Arc spans from start of phase day to end of phase day (center-to-center of beads)
      final arcStart = startAngle + (phase.start - 1) * sweepPerDay;
      final arcSweep = ((phaseEnd - phase.start) / totalDays) * (2 * pi);

      if (arcSweep <= 0) continue;

      arcPaint.color = phaseColor;
      canvas.drawArc(dialRect, arcStart, arcSweep, false, arcPaint);
    }

    // =========================================================================
    // PASS 4: Phase-colored filled beads on top of the arcs
    // Skips Day 1 (hollow ring), Day 14 (teal ring), activeDay (badge)
    // =========================================================================
    final animatedDayInt = effectiveDay.ceil();
    for (int day = 2; day <= animatedDayInt; day++) {
      if (day == 14 || day == activeDay) continue;

      final angle = startAngle + (day - 1) * sweepPerDay;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      final phaseColor = _getColorForDay(day);

      // White backing for crisp edges
      canvas.drawCircle(Offset(x, y), 5.0, Paint()
        ..color = theme.screenBackground
        ..style = PaintingStyle.fill);

      // Phase-colored bead
      canvas.drawCircle(Offset(x, y), 4.2, Paint()
        ..color = phaseColor
        ..style = PaintingStyle.fill);
    }

    // =========================================================================
    // PASS 5: Day 1 — Hollow pink ring (Period start marker)
    // =========================================================================
    {
      const angle = startAngle;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      canvas.drawCircle(Offset(x, y), 6.0, Paint()
        ..color = theme.screenBackground
        ..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, y), 6.0, Paint()
        ..color = theme.periodColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
    }

    // =========================================================================
    // PASS 6: Day 14 — Hollow teal ovulation ring + "OVULATION" label
    // =========================================================================
    {
      final day14Angle = startAngle + (14 - 1) * sweepPerDay;
      final day14X = center.dx + radius * cos(day14Angle);
      final day14Y = center.dy + radius * sin(day14Angle);

      final ovPulse = 1.0 + (0.07 * pulseProgress);
      final ovRadius = 7.5 * ovPulse;

      // Soft glow
      canvas.drawCircle(
        Offset(day14X, day14Y),
        ovRadius + 3.5,
        Paint()
          ..color = theme.ovulationHighlightColor.withValues(alpha: 0.18 + 0.10 * pulseProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
      );
      // White fill
      canvas.drawCircle(Offset(day14X, day14Y), ovRadius, Paint()
        ..color = theme.screenBackground
        ..style = PaintingStyle.fill);
      // Teal stroke
      canvas.drawCircle(Offset(day14X, day14Y), ovRadius, Paint()
        ..color = theme.ovulationHighlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);

      // "OVULATION" label — to the left of Day 14, inside the circle
      _drawOvulationLabel(canvas, center, radius, day14Angle, day14X, day14Y);
    }

    // =========================================================================
    // PASS 7: Active Selected Day Badge (filled circle + number + glow)
    // =========================================================================
    if (activeDay >= 1 && activeDay <= totalDays) {
      final activeAngle = startAngle + (activeDay - 1) * sweepPerDay;
      final activeX = center.dx + radius * cos(activeAngle);
      final activeY = center.dy + radius * sin(activeAngle);

      final activeColor = _getColorForDay(activeDay);
      final badgeScale = 1.0 + (0.055 * pulseProgress);
      final badgeRadius = 13.0 * badgeScale;

      // Colored ambient glow
      canvas.drawCircle(
        Offset(activeX, activeY),
        badgeRadius + 4.5,
        Paint()
          ..color = activeColor.withValues(alpha: 0.30 + 0.12 * pulseProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0),
      );
      // Badge fill
      canvas.drawCircle(Offset(activeX, activeY), badgeRadius, Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill);
      // Subtle white rim
      canvas.drawCircle(Offset(activeX, activeY), badgeRadius, Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0);

      // Day number
      final ts = TextSpan(
        text: '$activeDay',
        style: TextStyle(
          color: Colors.white,
          fontSize: activeDay > 9 ? 11.5 : 12.5,
          fontWeight: FontWeight.w800,
          fontFamily: theme.cycleDayLabelStyle.fontFamily,
        ),
      );
      final tp = TextPainter(text: ts, textAlign: TextAlign.center, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(activeX - tp.width / 2, activeY - tp.height / 2));
    }

    // =========================================================================
    // PASS 8: Cardinal Day Labels (1, 7, 14, 21, 28) — outside the ring
    // =========================================================================
    final labelRadius = radius + 19.0;
    _drawDayLabel(canvas, center, labelRadius, 1, startAngle);
    _drawDayLabel(canvas, center, labelRadius, 7, startAngle + (6 * sweepPerDay));
    _drawDayLabel(canvas, center, labelRadius, 14, startAngle + (13 * sweepPerDay));
    _drawDayLabel(canvas, center, labelRadius, 21, startAngle + (20 * sweepPerDay));
    _drawDayLabel(canvas, center, labelRadius, 28, startAngle + (27 * sweepPerDay));
  }

  /// Draws "OVULATION" label to the LEFT of Day 14 bead, inside the circle.
  /// Day 14 is at the bottom of the ring (~6 o'clock). In the reference image
  /// the label sits to the upper-left of Day 14, inside the ring.
  void _drawOvulationLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double day14Angle,
    double day14X,
    double day14Y,
  ) {
    final ts = TextSpan(
      text: 'OVULATION',
      style: TextStyle(
        color: theme.textSecondary.withValues(alpha: 0.55),
        fontSize: 9.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        fontFamily: theme.cycleDayLabelStyle.fontFamily,
      ),
    );
    final tp = TextPainter(text: ts, textAlign: TextAlign.center, textDirection: TextDirection.ltr)
      ..layout();

    // Position: slightly inside the ring, to the left of Day 14.
    // Day 14 sits near the bottom. Shift left by label width + small gap,
    // and slightly upward (inward) so the label right-edge is just before the ring bead.
    const horizontalGap = 6.0;
    const inwardShift = 10.0;
    final labelX = day14X - tp.width - horizontalGap;
    final labelY = day14Y - inwardShift - tp.height / 2;

    tp.paint(canvas, Offset(labelX, labelY));
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

    final ts = TextSpan(
      text: '$dayNumber',
      style: TextStyle(
        color: theme.textSecondary.withValues(alpha: 0.75),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        fontFamily: theme.cycleDayLabelStyle.fontFamily,
      ),
    );
    final tp = TextPainter(text: ts, textAlign: TextAlign.center, textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  Color _getColorForDay(int day) {
    if (day <= 5) return theme.periodColor;
    if (day <= 10) return theme.growthColor;
    if (day <= 13) return theme.peakColor;
    if (day == 14) return theme.ovulationHighlightColor;
    return theme.lutealColor;
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
