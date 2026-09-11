import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines the complete theme design system for RituRasa.
/// All UI widgets inherit their colors, dimensions, and typography
/// from this centralized Theme Engine via `context.rituTheme`.
class RituRasaThemeExtension extends ThemeExtension<RituRasaThemeExtension> {
  // Phase Colors: Period | Growth | Peak | Luteal
  final Color periodColor;
  final Color growthColor;
  final Color peakColor;
  final Color lutealColor;
  final Color ovulationHighlightColor;

  // Background & Surfaces
  final Color screenBackground;
  final Color cardBackground;
  final Color cardBorder;
  final Color cardShadow;
  final Color inactiveTrackColor;

  // Text Colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Pill & Badge Tokens
  final Color pillOvulationBg;
  final Color pillOvulationText;
  final Color pillNextPeriodBg;
  final Color pillNextPeriodText;
  final Color ovulationIconBg;
  final Color nextPeriodIconBg;

  // Typography Styles
  final TextStyle dateHeaderStyle;
  final TextStyle dateTitleStyle;
  final TextStyle cycleDayLabelStyle;
  final TextStyle cycleDayLargeStyle;
  final TextStyle cycleDayTotalStyle;
  final TextStyle cyclePhaseLabelStyle;
  final TextStyle legendTextStyle;
  final TextStyle cardTitleStyle;
  final TextStyle cardPillTextStyle;
  final TextStyle cardSubtitleStyle;

  const RituRasaThemeExtension({
    required this.periodColor,
    required this.growthColor,
    required this.peakColor,
    required this.lutealColor,
    required this.ovulationHighlightColor,
    required this.screenBackground,
    required this.cardBackground,
    required this.cardBorder,
    required this.cardShadow,
    required this.inactiveTrackColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.pillOvulationBg,
    required this.pillOvulationText,
    required this.pillNextPeriodBg,
    required this.pillNextPeriodText,
    required this.ovulationIconBg,
    required this.nextPeriodIconBg,
    required this.dateHeaderStyle,
    required this.dateTitleStyle,
    required this.cycleDayLabelStyle,
    required this.cycleDayLargeStyle,
    required this.cycleDayTotalStyle,
    required this.cyclePhaseLabelStyle,
    required this.legendTextStyle,
    required this.cardTitleStyle,
    required this.cardPillTextStyle,
    required this.cardSubtitleStyle,
  });

  /// Light theme definition (matches Figma design)
  factory RituRasaThemeExtension.light() {
    return RituRasaThemeExtension(
      // The 4 Core Phase Colors
      periodColor: const Color(0xFFFA2C56), // Vivid Coral/Pink-Red
      growthColor: const Color(0xFF4A90E2), // Crisp Sky Blue
      peakColor: const Color(0xFF8B5CF6), // Royal Lavender Purple
      lutealColor: const Color(0xFFE5E7EB), // Soft neutral grey/silver
      ovulationHighlightColor: const Color(0xFF10B981), // Emerald Mint

      // Surfaces
      screenBackground: const Color(0xFFFFFFFF),
      cardBackground: const Color(0xFFF9FAFB),
      cardBorder: const Color(0xFFF1F3F5),
      cardShadow: const Color(0x0A000000),
      inactiveTrackColor: const Color(0xFFE5E7EB),

      // Typography Colors
      textPrimary: const Color(0xFF111827),
      textSecondary: const Color(0xFF6B7280),
      textMuted: const Color(0xFF9CA3AF),

      // Badge & Pill Tokens
      pillOvulationBg: const Color(0xFFECFDF5),
      pillOvulationText: const Color(0xFF059669),
      pillNextPeriodBg: const Color(0xFFFFF1F2),
      pillNextPeriodText: const Color(0xFFE11D48),
      ovulationIconBg: const Color(0xFFF3F4F6),
      nextPeriodIconBg: const Color(0xFFFFE4E6),

      // Text Styles
      dateHeaderStyle: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B7280),
        letterSpacing: -0.2,
      ),
      dateTitleStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
        letterSpacing: -0.4,
      ),
      cycleDayLabelStyle: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B7280),
        letterSpacing: -0.2,
      ),
      cycleDayLargeStyle: GoogleFonts.outfit(
        fontSize: 58,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF111827),
        letterSpacing: -1.0,
      ),
      cycleDayTotalStyle: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF9CA3AF),
      ),
      cyclePhaseLabelStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF6B7280),
        letterSpacing: 1.2,
      ),
      legendTextStyle: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4B5563),
      ),
      cardTitleStyle: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
      ),
      cardPillTextStyle: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      cardSubtitleStyle: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF9CA3AF),
      ),
    );
  }

  @override
  ThemeExtension<RituRasaThemeExtension> copyWith({
    Color? periodColor,
    Color? growthColor,
    Color? peakColor,
    Color? lutealColor,
    Color? ovulationHighlightColor,
    Color? screenBackground,
    Color? cardBackground,
    Color? cardBorder,
    Color? cardShadow,
    Color? inactiveTrackColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? pillOvulationBg,
    Color? pillOvulationText,
    Color? pillNextPeriodBg,
    Color? pillNextPeriodText,
    Color? ovulationIconBg,
    Color? nextPeriodIconBg,
    TextStyle? dateHeaderStyle,
    TextStyle? dateTitleStyle,
    TextStyle? cycleDayLabelStyle,
    TextStyle? cycleDayLargeStyle,
    TextStyle? cycleDayTotalStyle,
    TextStyle? cyclePhaseLabelStyle,
    TextStyle? legendTextStyle,
    TextStyle? cardTitleStyle,
    TextStyle? cardPillTextStyle,
    TextStyle? cardSubtitleStyle,
  }) {
    return RituRasaThemeExtension(
      periodColor: periodColor ?? this.periodColor,
      growthColor: growthColor ?? this.growthColor,
      peakColor: peakColor ?? this.peakColor,
      lutealColor: lutealColor ?? this.lutealColor,
      ovulationHighlightColor: ovulationHighlightColor ?? this.ovulationHighlightColor,
      screenBackground: screenBackground ?? this.screenBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      inactiveTrackColor: inactiveTrackColor ?? this.inactiveTrackColor,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      pillOvulationBg: pillOvulationBg ?? this.pillOvulationBg,
      pillOvulationText: pillOvulationText ?? this.pillOvulationText,
      pillNextPeriodBg: pillNextPeriodBg ?? this.pillNextPeriodBg,
      pillNextPeriodText: pillNextPeriodText ?? this.pillNextPeriodText,
      ovulationIconBg: ovulationIconBg ?? this.ovulationIconBg,
      nextPeriodIconBg: nextPeriodIconBg ?? this.nextPeriodIconBg,
      dateHeaderStyle: dateHeaderStyle ?? this.dateHeaderStyle,
      dateTitleStyle: dateTitleStyle ?? this.dateTitleStyle,
      cycleDayLabelStyle: cycleDayLabelStyle ?? this.cycleDayLabelStyle,
      cycleDayLargeStyle: cycleDayLargeStyle ?? this.cycleDayLargeStyle,
      cycleDayTotalStyle: cycleDayTotalStyle ?? this.cycleDayTotalStyle,
      cyclePhaseLabelStyle: cyclePhaseLabelStyle ?? this.cyclePhaseLabelStyle,
      legendTextStyle: legendTextStyle ?? this.legendTextStyle,
      cardTitleStyle: cardTitleStyle ?? this.cardTitleStyle,
      cardPillTextStyle: cardPillTextStyle ?? this.cardPillTextStyle,
      cardSubtitleStyle: cardSubtitleStyle ?? this.cardSubtitleStyle,
    );
  }

  @override
  ThemeExtension<RituRasaThemeExtension> lerp(
    covariant ThemeExtension<RituRasaThemeExtension>? other,
    double t,
  ) {
    if (other is! RituRasaThemeExtension) return this;
    return RituRasaThemeExtension(
      periodColor: Color.lerp(periodColor, other.periodColor, t)!,
      growthColor: Color.lerp(growthColor, other.growthColor, t)!,
      peakColor: Color.lerp(peakColor, other.peakColor, t)!,
      lutealColor: Color.lerp(lutealColor, other.lutealColor, t)!,
      ovulationHighlightColor:
          Color.lerp(ovulationHighlightColor, other.ovulationHighlightColor, t)!,
      screenBackground: Color.lerp(screenBackground, other.screenBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      inactiveTrackColor: Color.lerp(inactiveTrackColor, other.inactiveTrackColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      pillOvulationBg: Color.lerp(pillOvulationBg, other.pillOvulationBg, t)!,
      pillOvulationText: Color.lerp(pillOvulationText, other.pillOvulationText, t)!,
      pillNextPeriodBg: Color.lerp(pillNextPeriodBg, other.pillNextPeriodBg, t)!,
      pillNextPeriodText: Color.lerp(pillNextPeriodText, other.pillNextPeriodText, t)!,
      ovulationIconBg: Color.lerp(ovulationIconBg, other.ovulationIconBg, t)!,
      nextPeriodIconBg: Color.lerp(nextPeriodIconBg, other.nextPeriodIconBg, t)!,
      dateHeaderStyle: TextStyle.lerp(dateHeaderStyle, other.dateHeaderStyle, t)!,
      dateTitleStyle: TextStyle.lerp(dateTitleStyle, other.dateTitleStyle, t)!,
      cycleDayLabelStyle: TextStyle.lerp(cycleDayLabelStyle, other.cycleDayLabelStyle, t)!,
      cycleDayLargeStyle: TextStyle.lerp(cycleDayLargeStyle, other.cycleDayLargeStyle, t)!,
      cycleDayTotalStyle: TextStyle.lerp(cycleDayTotalStyle, other.cycleDayTotalStyle, t)!,
      cyclePhaseLabelStyle: TextStyle.lerp(cyclePhaseLabelStyle, other.cyclePhaseLabelStyle, t)!,
      legendTextStyle: TextStyle.lerp(legendTextStyle, other.legendTextStyle, t)!,
      cardTitleStyle: TextStyle.lerp(cardTitleStyle, other.cardTitleStyle, t)!,
      cardPillTextStyle: TextStyle.lerp(cardPillTextStyle, other.cardPillTextStyle, t)!,
      cardSubtitleStyle: TextStyle.lerp(cardSubtitleStyle, other.cardSubtitleStyle, t)!,
    );
  }
}

/// Convenience extension on BuildContext so all widgets can inherit
/// theme styles with `context.rituTheme`.
extension RituRasaThemeContext on BuildContext {
  RituRasaThemeExtension get rituTheme =>
      Theme.of(this).extension<RituRasaThemeExtension>() ?? RituRasaThemeExtension.light();
}
