import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/core/widgets/pressable_scale.dart';

/// Standalone Hydration Tracking Card matching the policy:
/// Water is tracked as its own distinct card with quick logging (+250ml / 1 glass).
class HydrationCard extends StatefulWidget {
  final int initialIntakeMl;
  final int targetMl;
  final ValueChanged<int>? onIntakeChanged;

  const HydrationCard({
    super.key,
    this.initialIntakeMl = 1500,
    this.targetMl = 2500,
    this.onIntakeChanged,
  });

  @override
  State<HydrationCard> createState() => _HydrationCardState();
}

class _HydrationCardState extends State<HydrationCard> {
  late int _intakeMl;

  @override
  void initState() {
    super.initState();
    _intakeMl = widget.initialIntakeMl;
  }

  void _addGlass() {
    setState(() {
      _intakeMl = (_intakeMl + 250).clamp(0, widget.targetMl + 1000);
    });
    widget.onIntakeChanged?.call(_intakeMl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;
    final progress = (_intakeMl / widget.targetMl).clamp(0.0, 1.0);
    final glasses = (_intakeMl / 250).round();
    final targetGlasses = (widget.targetMl / 250).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.hydrationCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.hydrationCategoryColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Droplet / Water Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.hydrationCategoryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: theme.hydrationCategoryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title & Glass Count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydration Tracker',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$glasses of $targetGlasses glasses logged',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Add 1 Glass Button with Tactile PressableScale
              PressableScale(
                onTap: _addGlass,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: theme.hydrationCategoryColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: theme.hydrationCategoryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '1 Glass',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Fluid Animated Progress Indicator
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, animatedVal, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: animatedVal,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.hydrationCategoryColor),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Bottom Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_intakeMl / ${widget.targetMl} ml',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.textPrimary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Reached',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.hydrationCategoryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
