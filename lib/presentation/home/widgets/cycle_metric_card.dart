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

    return Expanded(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: theme.cardBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: theme.cardShadow,
                blurRadius: 10.0,
                offset: const Offset(0, 4),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                      border: iconBorder ?? Border.all(color: theme.cardBorder, width: 1.0),
                    ),
                    alignment: Alignment.center,
                    child: icon,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.cardTitleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Middle Row: Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: pillBgColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  pillText,
                  style: theme.cardPillTextStyle.copyWith(color: pillTextColor),
                ),
              ),
              const SizedBox(height: 12),

              // Bottom Row: Subtitle
              Text(
                subtitle,
                style: theme.cardSubtitleStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
