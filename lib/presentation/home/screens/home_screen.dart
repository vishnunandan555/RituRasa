import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/riturasa_theme.dart';
import '../../../features/cycle/cycle_controller.dart';
import '../widgets/cycle_metric_card.dart';
import '../widgets/cycle_wheel.dart';
import '../widgets/phase_legend.dart';

/// RituRasa Home Screen featuring the 28-day circular cycle tracker dial
/// and key physiological phase metrics.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Default interactive day initialized to 12 (matching design screenshot)
  int _activeDay = 12;

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final cycleState = ref.watch(cycleNotifierProvider);

    // Current date formatting (matching "December 21, Sunday" style)
    final now = DateTime.now();
    final dateTitle = DateFormat('MMMM d, EEEE').format(now);

    // If local database has calculated cycle state, reflect it;
    // otherwise fallback gracefully to the 12/28 screenshot state.
    final currentDay = cycleState.currentState?.currentCycleDay ?? _activeDay;
    final totalDays = cycleState.latestRecord?.cycleLength ?? 28;
    final currentPhase = _getPhaseNameForDay(currentDay);

    // Metric Calculations
    final daysToOvulation = (14 - currentDay) > 0 ? (14 - currentDay) : (totalDays - currentDay + 14);
    final daysToNextPeriod = cycleState.currentState?.daysUntilNextPeriod ?? (totalDays - currentDay + 1);
    final nextPeriodDate = cycleState.currentState?.estimatedNextPeriod ??
        now.add(Duration(days: daysToNextPeriod));
    final nextPeriodFormatted = DateFormat('MMMM d, yyyy').format(nextPeriodDate);

    return Scaffold(
      backgroundColor: theme.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),

                // 1. Top Date Header
                Column(
                  children: [
                    Text(
                      'Today',
                      style: theme.dateHeaderStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateTitle,
                      style: theme.dateTitleStyle,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                    .slideY(begin: -0.15, end: 0),

                const SizedBox(height: 28),

                // 2. Center Circular Cycle Wheel Dial
                CycleWheel(
                  currentCycleDay: currentDay,
                  totalCycleDays: totalDays,
                  currentPhaseName: currentPhase,
                  onDaySelected: (day) {
                    setState(() {
                      _activeDay = day;
                    });
                  },
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 100.ms)
                    .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.0, 1.0)),

                const SizedBox(height: 28),

                // 3. Four-Phase Legend Row (Period | Growth | Peak | Luteal)
                PhaseLegend(activePhase: currentPhase)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 250.ms),

                const SizedBox(height: 36),

                // 4. Two Bottom Cards (Ovulation & Next Period)
                Row(
                  children: [
                    // Left Card: Ovulation
                    CycleMetricCard(
                      icon: Icon(
                        Icons.egg_outlined,
                        size: 20,
                        color: theme.textSecondary,
                      ),
                      iconBgColor: theme.ovulationIconBg,
                      title: 'Ovulation',
                      pillText: 'in $daysToOvulation days',
                      pillBgColor: theme.pillOvulationBg,
                      pillTextColor: theme.pillOvulationText,
                      subtitle: 'Day 14',
                      onTap: () {
                        setState(() {
                          _activeDay = 14;
                        });
                      },
                    ),

                    const SizedBox(width: 14),

                    // Right Card: Next Period
                    CycleMetricCard(
                      icon: Icon(
                        Icons.water_drop_rounded,
                        size: 20,
                        color: theme.periodColor,
                      ),
                      iconBgColor: theme.nextPeriodIconBg,
                      title: 'Next Period',
                      pillText: 'in $daysToNextPeriod days',
                      pillBgColor: theme.pillNextPeriodBg,
                      pillTextColor: theme.pillNextPeriodText,
                      subtitle: nextPeriodFormatted,
                      onTap: () {
                        setState(() {
                          _activeDay = 1;
                        });
                      },
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 700.ms, delay: 350.ms)
                    .slideY(begin: 0.15, end: 0),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPhaseNameForDay(int day) {
    if (day <= 5) {
      return 'Period';
    } else if (day <= 11) {
      return 'Growth';
    } else if (day <= 16) {
      return day == 14 ? 'Ovulation' : 'Peak';
    } else {
      return 'Luteal';
    }
  }
}
