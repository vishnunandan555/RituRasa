import 'package:flutter/material.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// Renders the 4-phase legend row:
/// Period | Growth | Peak | Luteal
class PhaseLegend extends StatelessWidget {
  final String? activePhase;

  const PhaseLegend({
    super.key,
    this.activePhase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: theme.periodColor,
              label: 'Period',
              isActive: activePhase?.toLowerCase() == 'period',
              theme: theme,
            ),
            const SizedBox(width: 14),
            _LegendItem(
              color: theme.growthColor,
              label: 'Growth',
              isActive: activePhase?.toLowerCase() == 'growth',
              theme: theme,
            ),
            const SizedBox(width: 14),
            _LegendItem(
              color: theme.peakColor,
              label: 'Peak',
              isActive: activePhase?.toLowerCase() == 'peak' || activePhase?.toLowerCase() == 'ovulation',
              theme: theme,
            ),
            const SizedBox(width: 14),
            _LegendItem(
              color: theme.lutealColor,
              label: 'Luteal',
              isActive: activePhase?.toLowerCase() == 'luteal',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isActive;
  final RituRasaThemeExtension theme;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isActive,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.legendTextStyle.copyWith(
            color: isActive ? theme.textPrimary : theme.textSecondary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
