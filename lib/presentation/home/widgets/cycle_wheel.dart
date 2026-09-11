import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/riturasa_theme.dart';
import 'cycle_wheel_painter.dart';

/// Interactive animated circular cycle tracker dial matching the screenshot.
class CycleWheel extends StatefulWidget {
  final int currentCycleDay;
  final int totalCycleDays;
  final String currentPhaseName;
  final ValueChanged<int>? onDaySelected;

  const CycleWheel({
    super.key,
    required this.currentCycleDay,
    this.totalCycleDays = 28,
    required this.currentPhaseName,
    this.onDaySelected,
  });

  @override
  State<CycleWheel> createState() => _CycleWheelState();
}

class _CycleWheelState extends State<CycleWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.currentCycleDay;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CycleWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCycleDay != widget.currentCycleDay) {
      setState(() {
        _selectedDay = widget.currentCycleDay;
      });
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanOrTap(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    // Calculate angle in radians clockwise from top (-pi/2)
    var angle = atan2(dy, dx) + (pi / 2);
    if (angle < 0) angle += 2 * pi;

    final sweepPerDay = (2 * pi) / widget.totalCycleDays;
    final tappedDay = ((angle / sweepPerDay).round() % widget.totalCycleDays) + 1;

    if (tappedDay != _selectedDay && tappedDay >= 1 && tappedDay <= widget.totalCycleDays) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedDay = tappedDay;
      });
      widget.onDaySelected?.call(tappedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    const dialSize = 280.0;

    return Center(
      child: GestureDetector(
        onPanUpdate: (details) => _handlePanOrTap(details.localPosition, const Size(dialSize, dialSize)),
        onTapDown: (details) => _handlePanOrTap(details.localPosition, const Size(dialSize, dialSize)),
        child: SizedBox(
          width: dialSize,
          height: dialSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Custom Wheel Painter
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(dialSize, dialSize),
                    painter: CycleWheelPainter(
                      totalDays: widget.totalCycleDays,
                      currentCycleDay: widget.currentCycleDay.toDouble(),
                      activeDay: _selectedDay,
                      theme: theme,
                      animationProgress: _progressAnimation.value,
                    ),
                  );
                },
              ),

              // 2. Central Content (Cycle Day & Big Number)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cycle Day',
                    style: theme.cycleDayLabelStyle,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // Animated Number Counter
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, _) {
                          final animatedDisplayDay = (_selectedDay * _progressAnimation.value).round();
                          return Text(
                            '$animatedDisplayDay',
                            style: theme.cycleDayLargeStyle,
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ ${widget.totalCycleDays}',
                        style: theme.cycleDayTotalStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Phase Badge text
                  Text(
                    widget.currentPhaseName.toUpperCase(),
                    style: theme.cyclePhaseLabelStyle.copyWith(
                      color: _getPhaseColor(widget.currentPhaseName, theme),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPhaseColor(String phaseName, RituRasaThemeExtension theme) {
    return switch (phaseName.toLowerCase()) {
      'period' => theme.periodColor,
      'growth' => theme.growthColor,
      'peak' || 'ovulation' => theme.peakColor,
      'luteal' => theme.textSecondary,
      _ => theme.textSecondary,
    };
  }
}
