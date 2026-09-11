import 'dart:math';
import 'package:flutter/material.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// CustomPainter drawing the 28-day circular cycle tracker.
///
/// Refined & professional layout:
/// - Perfectly balanced diameter matching reference aesthetics.
/// - Full circle of small, dainty light-gray inactive beads.
/// - Crisp per-phase colored arc strokes connecting active days.
/// - Phase-colored filled beads on top of the arc strokes.
/// - Day 1 as a hollow pink ring. Day 14 as a hollow teal ring.
/// - Clean "OVULATION" label positioned comfortably inside the arc without bead collision.
/// - Active selected day as a clean filled badge with the day number.
/// - Cardinal day labels (1, 7, 14, 21, 28) outside the ring with generous spacing.
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

  // Continuous 4-phase boundaries connecting seamlessly
  static const _phaseBoundaries = [
    (start: 1.0, end: 5.0, name: 'Period'),
    (start: 5.0, end: 10.0, name: 'Growth'),
    (start: 10.0, end: 14.0, name: 'Peak'),
    (start: 14.0, end: 28.0, name: 'Luteal'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Radius leaves room for outside day labels
    final radius = (min(size.width, size.height) / 2) - 16.0;

    const startAngle = -pi / 2;
    final sweepPerDay = (2 * pi) / totalDays;

    // Effective animated day progress (clamped)
    final effectiveDay = (currentCycleDay * animationProgress).clamp(1.0, totalDays.toDouble());

    // =========================================================================
    // PASS 1: Base circle track (subtle light gray)
    // =========================================================================
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFE5E7EB).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
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
        2.8,
        Paint()
          ..color = const Color(0xFFE5E7EB)
          ..style = PaintingStyle.fill,
      );
    }

    // =========================================================================
    // PASS 3: Seamless continuous per-phase solid colored arc strokes
    // =========================================================================
    final dialRect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round;

    for (final phase in _phaseBoundaries) {
      if (phase.start >= effectiveDay) break;

      final phaseColor = _getPhaseColor(phase.name);
      final phaseEnd = phase.end.clamp(phase.start, effectiveDay);

      // Arc spans continuously from phase.start to phaseEnd with zero gaps
      final arcStart = startAngle + (phase.start - 1) * sweepPerDay;
      final arcSweep = ((phaseEnd - phase.start) / totalDays) * (2 * pi);

      if (arcSweep <= 0) continue;

      arcPaint.color = phaseColor;
      canvas.drawArc(dialRect, arcStart, arcSweep, false, arcPaint);
    }

    // =========================================================================
    // PASS 4: Phase-colored filled beads on top of the arcs
    // =========================================================================
    final animatedDayInt = effectiveDay.ceil();
    for (int day = 2; day <= animatedDayInt; day++) {
      if (day == 14 || day == activeDay) continue;

      final angle = startAngle + (day - 1) * sweepPerDay;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      final phaseColor = _getColorForDay(day);

      // Crisp white backing
      canvas.drawCircle(Offset(x, y), 5.0, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill);

      // Phase-colored bead
      canvas.drawCircle(Offset(x, y), 3.8, Paint()
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

      canvas.drawCircle(Offset(x, y), 5.2, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, y), 5.2, Paint()
        ..color = theme.periodColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4);
    }

    // =========================================================================
    // PASS 6: Day 14 — Hollow teal ovulation ring
    // =========================================================================
    {
      final day14Angle = startAngle + (14 - 1) * sweepPerDay;
      final day14X = center.dx + radius * cos(day14Angle);
      final day14Y = center.dy + radius * sin(day14Angle);

      final ovPulse = 1.0 + (0.06 * pulseProgress);
      final ovRadius = 6.8 * ovPulse;

      // Soft glow
      canvas.drawCircle(
        Offset(day14X, day14Y),
        ovRadius + 3.0,
        Paint()
          ..color = theme.ovulationHighlightColor.withValues(alpha: 0.20 + 0.10 * pulseProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
      );
      // White fill
      canvas.drawCircle(Offset(day14X, day14Y), ovRadius, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill);
      // Teal stroke
      canvas.drawCircle(Offset(day14X, day14Y), ovRadius, Paint()
        ..color = theme.ovulationHighlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6);
    }

    // =========================================================================
    // PASS 7: Active Selected Day Badge (filled circle + number + glow)
    // =========================================================================
    if (activeDay >= 1 && activeDay <= totalDays) {
      final activeAngle = startAngle + (activeDay - 1) * sweepPerDay;
      final activeX = center.dx + radius * cos(activeAngle);
      final activeY = center.dy + radius * sin(activeAngle);

      final activeColor = _getColorForDay(activeDay);
      final badgeScale = 1.0 + (0.04 * pulseProgress);
      final badgeRadius = 11.5 * badgeScale;

      // Colored ambient glow
      canvas.drawCircle(
        Offset(activeX, activeY),
        badgeRadius + 4.0,
        Paint()
          ..color = activeColor.withValues(alpha: 0.28 + 0.10 * pulseProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
      );
      // Badge fill
      canvas.drawCircle(Offset(activeX, activeY), badgeRadius, Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill);
      // Subtle white rim
      canvas.drawCircle(Offset(activeX, activeY), badgeRadius, Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0);

      // Day number
      final ts = TextSpan(
        text: '$activeDay',
        style: TextStyle(
          color: Colors.white,
          fontSize: activeDay > 9 ? 10.5 : 11.5,
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
    final labelRadius = radius + 13.5;
    _drawDayLabel(canvas, center, labelRadius, 1, startAngle);
    _drawDayLabel(canvas, center, labelRadius, 7, startAngle + (6 * sweepPerDay));
    _drawDayLabel(canvas, center, labelRadius, 14, startAngle + (13 * sweepPerDay));
    _drawDayLabel(canvas, center, labelRadius, 21, startAngle + (20 * sweepPerDay));
    _drawDayLabel(canvas, center, labelRadius, 28, startAngle + (27 * sweepPerDay));
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
        color: const Color(0xFF9CA3AF),
        fontSize: 10.5,
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
    if (day <= 14) return theme.peakColor;
    return theme.lutealColor;
  }

  Color _getPhaseColor(String phaseName) {
    return switch (phaseName.toLowerCase()) {
      'period' => theme.periodColor,
      'growth' => theme.growthColor,
      'peak' => theme.peakColor,
      _ => theme.lutealColor,
    };
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
