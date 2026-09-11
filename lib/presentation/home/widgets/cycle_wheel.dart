import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'cycle_wheel_painter.dart';

/// Interactive animated circular cycle tracker dial.
/// Features:
/// - Continuous sweep gradient arc (zero color overlap/bleeding)
/// - Multi-pass crisp bead rendering
/// - Breathing pulse animation on active day badge & Day 14 ovulation highlight
/// - Fluid animated day transition on touch and drag with tactile haptics
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

class _CycleWheelState extends State<CycleWheel> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _entryProgressAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _dayGlideController;
  late Animation<double> _dayGlideAnimation;

  late int _selectedDay;
  late double _currentAnimatedDay;
  double _previousAnimatedDay = 1.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.currentCycleDay;
    _currentAnimatedDay = widget.currentCycleDay.toDouble();
    _previousAnimatedDay = _currentAnimatedDay;

    // 1. Initial Entry Reveal Animation (crisp, decisive sweep)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _entryProgressAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutQuart,
    );

    // 2. Continuous Breathing Pulse Animation for active badge & ovulation ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.value = 1.0;
    }
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );

    // 3. Fluid Day Glide Animation (when user drags or taps new day)
    _dayGlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _dayGlideAnimation = Tween<double>(
      begin: _previousAnimatedDay,
      end: _currentAnimatedDay,
    ).animate(CurvedAnimation(
      parent: _dayGlideController,
      curve: Curves.easeOutCubic,
    ));

    _entryController.forward();
  }

  @override
  void didUpdateWidget(covariant CycleWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCycleDay != widget.currentCycleDay) {
      _glideToDay(widget.currentCycleDay);
    }
  }

  void _glideToDay(int newDay) {
    _previousAnimatedDay = _dayGlideAnimation.value;
    _selectedDay = newDay;
    _currentAnimatedDay = newDay.toDouble();

    _dayGlideAnimation = Tween<double>(
      begin: _previousAnimatedDay,
      end: _currentAnimatedDay,
    ).animate(CurvedAnimation(
      parent: _dayGlideController,
      curve: Curves.easeOutCubic,
    ));

    _dayGlideController.forward(from: 0.0);
    setState(() {});
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _dayGlideController.dispose();
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
      _glideToDay(tappedDay);
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
              // 1. Custom Wheel Painter with Animated Builders
              AnimatedBuilder(
                animation: Listenable.merge([
                  _entryProgressAnimation,
                  _pulseAnimation,
                  _dayGlideAnimation,
                ]),
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(dialSize, dialSize),
                    painter: CycleWheelPainter(
                      totalDays: widget.totalCycleDays,
                      currentCycleDay: _dayGlideAnimation.value,
                      activeDay: _selectedDay,
                      theme: theme,
                      animationProgress: _entryProgressAnimation.value,
                      pulseProgress: _pulseAnimation.value,
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
                        animation: _entryProgressAnimation,
                        builder: (context, _) {
                          final animatedDisplayDay = (_selectedDay * _entryProgressAnimation.value).round();
                          return Text(
                            '$animatedDisplayDay',
                            style: theme.cycleDayLargeStyle,
                          );
                        },
                      ),
                      Text(
                        '/${widget.totalCycleDays}',
                        style: theme.cycleDayTotalStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Phase Label (Subtle spaced uppercase matching screenshot e.g. OVULATION)
                  Text(
                    _getPhaseNameForDay(_selectedDay).toUpperCase(),
                    style: theme.cyclePhaseLabelStyle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: theme.textSecondary.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }

  String _getPhaseNameForDay(int day) {
    if (day <= 5) return 'Period';
    if (day <= 10) return 'Fertile';
    if (day <= 14) return 'Ovulation';
    return 'Luteal';
  }
}
