import 'package:flutter/material.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';

/// Card component for Ovulation and Next Period metric highlights.
class CycleMetricCard extends StatelessWidget {
  final Widget icon;
  final Color iconBgColor;
  final String title;
  final String pillText;
  final Color pillBgColor;
  final Color pillTextColor;
  final String subtitle;
  final BoxBorder? iconBorder;
  final VoidCallback? onTap;

  const CycleMetricCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    this.iconBorder,
    required this.title,
    required this.pillText,
    required this.pillBgColor,
    required this.pillTextColor,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    final isCompact = theme.isCompact;

    return Expanded(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10.0 : 12.0,
            vertical: isCompact ? 10.0 : 12.0,
          ),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: theme.cardBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: theme.cardShadow,
                blurRadius: 8.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Circular Icon + Title
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                      border: iconBorder ?? Border.all(color: theme.cardBorder, width: 1.0),
                    ),
                    alignment: Alignment.center,
                    child: icon,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: theme.cardTitleStyle.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Middle Row: Pill Badge (with FittedBox to prevent text wrapping)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9.0,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: pillBgColor,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    pillText,
                    style: theme.cardPillTextStyle.copyWith(
                      color: pillTextColor,
                      fontSize: 11.5,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Bottom Row: Subtitle
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: theme.cardSubtitleStyle.copyWith(fontSize: 11.5),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
