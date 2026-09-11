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

  // Navigation Bar Tokens (All-White Theme Equivalent)
  final Color navBarBackground;
  final Color navBarBorder;
  final Color navBarShadow;
  final Color navBarActivePill;
  final Color navBarActiveContent;
  final Color navBarInactiveContent;

  // Chip & Action Tokens
  final Color chipSelectedBg;
  final Color chipSelectedText;
  final Color chipUnselectedBg;
  final Color chipUnselectedText;

  // Nutrition Category Progress Tokens
  final Color energyCategoryColor;
  final Color macroCategoryColor;
  final Color vitaminsCategoryColor;
  final Color mineralsCategoryColor;
  final Color hydrationCategoryColor;

  // Category Sub-Card Tinted Surfaces (Matches Reference Design)
  final Color energySubCardBg;
  final Color macroSubCardBg;
  final Color vitaminsSubCardBg;
  final Color mineralsSubCardBg;
  final Color hydrationCardBg;

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
  final TextStyle screenTitleStyle;
  final TextStyle screenSubtitleStyle;
  final TextStyle sectionHeaderStyle;
  final TextStyle dialPercentageStyle;

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
    required this.navBarBackground,
    required this.navBarBorder,
    required this.navBarShadow,
    required this.navBarActivePill,
    required this.navBarActiveContent,
    required this.navBarInactiveContent,
    required this.chipSelectedBg,
    required this.chipSelectedText,
    required this.chipUnselectedBg,
    required this.chipUnselectedText,
    required this.energyCategoryColor,
    required this.macroCategoryColor,
    required this.vitaminsCategoryColor,
    required this.mineralsCategoryColor,
    required this.hydrationCategoryColor,
    required this.energySubCardBg,
    required this.macroSubCardBg,
    required this.vitaminsSubCardBg,
    required this.mineralsSubCardBg,
    required this.hydrationCardBg,
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
    required this.screenTitleStyle,
    required this.screenSubtitleStyle,
    required this.sectionHeaderStyle,
    required this.dialPercentageStyle,
  });

  /// Light theme definition (All-White Minimalist Aesthetic)
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

      // Floating Nav Bar Tokens (White Theme Equivalent)
      navBarBackground: const Color(0xFFFFFFFF),
      navBarBorder: const Color(0xFFE5E7EB),
      navBarShadow: const Color(0x18000000),
      navBarActivePill: const Color(0xFF18181B), // Crisp obsidian black pill
      navBarActiveContent: const Color(0xFFFFFFFF), // White icon and label
      navBarInactiveContent: const Color(0xFF6B7280), // Sleek slate grey

      // Chip Tokens
      chipSelectedBg: const Color(0xFF18181B),
      chipSelectedText: const Color(0xFFFFFFFF),
      chipUnselectedBg: const Color(0xFFF3F4F6),
      chipUnselectedText: const Color(0xFF4B5563),

      // Nutrition Categories
      energyCategoryColor: const Color(0xFF2563EB), // Vibrant Royal Blue (like circular ring)
      macroCategoryColor: const Color(0xFF00BFA5),  // Mint Teal (like Steps)
      vitaminsCategoryColor: const Color(0xFF10B981), // Fresh Green (like Readiness)
      mineralsCategoryColor: const Color(0xFF8B5CF6), // Royal Lavender (like Sleep card)
      hydrationCategoryColor: const Color(0xFF06B6D4), // Ocean Aqua Cyan

      // Sub-Card Tinted Backgrounds
      energySubCardBg: const Color(0xFFEFF6FF), // Soft Blue tint
      macroSubCardBg: const Color(0xFFE6FBF7),  // Soft Teal tint
      vitaminsSubCardBg: const Color(0xFFEBF9E8), // Soft Sage tint
      mineralsSubCardBg: const Color(0xFFF4EEFD), // Soft Lavender tint
      hydrationCardBg: const Color(0xFFECFEFF), // Soft Cyan tint

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
      screenTitleStyle: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
        letterSpacing: -0.3,
      ),
      screenSubtitleStyle: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B7280),
      ),
      sectionHeaderStyle: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
        letterSpacing: -0.2,
      ),
      dialPercentageStyle: GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF111827),
        letterSpacing: -0.8,
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
    Color? navBarBackground,
    Color? navBarBorder,
    Color? navBarShadow,
    Color? navBarActivePill,
    Color? navBarActiveContent,
    Color? navBarInactiveContent,
    Color? chipSelectedBg,
    Color? chipSelectedText,
    Color? chipUnselectedBg,
    Color? chipUnselectedText,
    Color? energyCategoryColor,
    Color? macroCategoryColor,
    Color? vitaminsCategoryColor,
    Color? mineralsCategoryColor,
    Color? hydrationCategoryColor,
    Color? energySubCardBg,
    Color? macroSubCardBg,
    Color? vitaminsSubCardBg,
    Color? mineralsSubCardBg,
    Color? hydrationCardBg,
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
    TextStyle? screenTitleStyle,
    TextStyle? screenSubtitleStyle,
    TextStyle? sectionHeaderStyle,
    TextStyle? dialPercentageStyle,
  }) {
    return RituRasaThemeExtension(
      periodColor: periodColor ?? this.periodColor,
      growthColor: growthColor ?? this.growthColor,
      peakColor: peakColor ?? this.peakColor,
      lutealColor: lutealColor ?? this.lutealColor,
      ovulationHighlightColor:
          ovulationHighlightColor ?? this.ovulationHighlightColor,
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
      navBarBackground: navBarBackground ?? this.navBarBackground,
      navBarBorder: navBarBorder ?? this.navBarBorder,
      navBarShadow: navBarShadow ?? this.navBarShadow,
      navBarActivePill: navBarActivePill ?? this.navBarActivePill,
      navBarActiveContent: navBarActiveContent ?? this.navBarActiveContent,
      navBarInactiveContent:
          navBarInactiveContent ?? this.navBarInactiveContent,
      chipSelectedBg: chipSelectedBg ?? this.chipSelectedBg,
      chipSelectedText: chipSelectedText ?? this.chipSelectedText,
      chipUnselectedBg: chipUnselectedBg ?? this.chipUnselectedBg,
      chipUnselectedText: chipUnselectedText ?? this.chipUnselectedText,
      energyCategoryColor: energyCategoryColor ?? this.energyCategoryColor,
      macroCategoryColor: macroCategoryColor ?? this.macroCategoryColor,
      vitaminsCategoryColor: vitaminsCategoryColor ?? this.vitaminsCategoryColor,
      mineralsCategoryColor: mineralsCategoryColor ?? this.mineralsCategoryColor,
      hydrationCategoryColor: hydrationCategoryColor ?? this.hydrationCategoryColor,
      energySubCardBg: energySubCardBg ?? this.energySubCardBg,
      macroSubCardBg: macroSubCardBg ?? this.macroSubCardBg,
      vitaminsSubCardBg: vitaminsSubCardBg ?? this.vitaminsSubCardBg,
      mineralsSubCardBg: mineralsSubCardBg ?? this.mineralsSubCardBg,
      hydrationCardBg: hydrationCardBg ?? this.hydrationCardBg,
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
      screenTitleStyle: screenTitleStyle ?? this.screenTitleStyle,
      screenSubtitleStyle: screenSubtitleStyle ?? this.screenSubtitleStyle,
      sectionHeaderStyle: sectionHeaderStyle ?? this.sectionHeaderStyle,
      dialPercentageStyle: dialPercentageStyle ?? this.dialPercentageStyle,
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
      inactiveTrackColor:
          Color.lerp(inactiveTrackColor, other.inactiveTrackColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      pillOvulationBg: Color.lerp(pillOvulationBg, other.pillOvulationBg, t)!,
      pillOvulationText:
          Color.lerp(pillOvulationText, other.pillOvulationText, t)!,
      pillNextPeriodBg: Color.lerp(pillNextPeriodBg, other.pillNextPeriodBg, t)!,
      pillNextPeriodText:
          Color.lerp(pillNextPeriodText, other.pillNextPeriodText, t)!,
      ovulationIconBg: Color.lerp(ovulationIconBg, other.ovulationIconBg, t)!,
      nextPeriodIconBg:
          Color.lerp(nextPeriodIconBg, other.nextPeriodIconBg, t)!,
      navBarBackground:
          Color.lerp(navBarBackground, other.navBarBackground, t)!,
      navBarBorder: Color.lerp(navBarBorder, other.navBarBorder, t)!,
      navBarShadow: Color.lerp(navBarShadow, other.navBarShadow, t)!,
      navBarActivePill:
          Color.lerp(navBarActivePill, other.navBarActivePill, t)!,
      navBarActiveContent:
          Color.lerp(navBarActiveContent, other.navBarActiveContent, t)!,
      navBarInactiveContent:
          Color.lerp(navBarInactiveContent, other.navBarInactiveContent, t)!,
      chipSelectedBg: Color.lerp(chipSelectedBg, other.chipSelectedBg, t)!,
      chipSelectedText:
          Color.lerp(chipSelectedText, other.chipSelectedText, t)!,
      chipUnselectedBg:
          Color.lerp(chipUnselectedBg, other.chipUnselectedBg, t)!,
      chipUnselectedText:
          Color.lerp(chipUnselectedText, other.chipUnselectedText, t)!,
      energyCategoryColor:
          Color.lerp(energyCategoryColor, other.energyCategoryColor, t)!,
      macroCategoryColor:
          Color.lerp(macroCategoryColor, other.macroCategoryColor, t)!,
      vitaminsCategoryColor:
          Color.lerp(vitaminsCategoryColor, other.vitaminsCategoryColor, t)!,
      mineralsCategoryColor:
          Color.lerp(mineralsCategoryColor, other.mineralsCategoryColor, t)!,
      hydrationCategoryColor:
          Color.lerp(hydrationCategoryColor, other.hydrationCategoryColor, t)!,
      energySubCardBg: Color.lerp(energySubCardBg, other.energySubCardBg, t)!,
      macroSubCardBg: Color.lerp(macroSubCardBg, other.macroSubCardBg, t)!,
      vitaminsSubCardBg:
          Color.lerp(vitaminsSubCardBg, other.vitaminsSubCardBg, t)!,
      mineralsSubCardBg:
          Color.lerp(mineralsSubCardBg, other.mineralsSubCardBg, t)!,
      hydrationCardBg: Color.lerp(hydrationCardBg, other.hydrationCardBg, t)!,
      dateHeaderStyle: TextStyle.lerp(dateHeaderStyle, other.dateHeaderStyle, t)!,
      dateTitleStyle: TextStyle.lerp(dateTitleStyle, other.dateTitleStyle, t)!,
      cycleDayLabelStyle:
          TextStyle.lerp(cycleDayLabelStyle, other.cycleDayLabelStyle, t)!,
      cycleDayLargeStyle:
          TextStyle.lerp(cycleDayLargeStyle, other.cycleDayLargeStyle, t)!,
      cycleDayTotalStyle:
          TextStyle.lerp(cycleDayTotalStyle, other.cycleDayTotalStyle, t)!,
      cyclePhaseLabelStyle:
          TextStyle.lerp(cyclePhaseLabelStyle, other.cyclePhaseLabelStyle, t)!,
      legendTextStyle: TextStyle.lerp(legendTextStyle, other.legendTextStyle, t)!,
      cardTitleStyle: TextStyle.lerp(cardTitleStyle, other.cardTitleStyle, t)!,
      cardPillTextStyle:
          TextStyle.lerp(cardPillTextStyle, other.cardPillTextStyle, t)!,
      cardSubtitleStyle:
          TextStyle.lerp(cardSubtitleStyle, other.cardSubtitleStyle, t)!,
      screenTitleStyle:
          TextStyle.lerp(screenTitleStyle, other.screenTitleStyle, t)!,
      screenSubtitleStyle:
          TextStyle.lerp(screenSubtitleStyle, other.screenSubtitleStyle, t)!,
      sectionHeaderStyle:
          TextStyle.lerp(sectionHeaderStyle, other.sectionHeaderStyle, t)!,
      dialPercentageStyle:
          TextStyle.lerp(dialPercentageStyle, other.dialPercentageStyle, t)!,
    );
  }
}

/// Convenience extension on BuildContext so all widgets can inherit
/// theme styles with `context.rituTheme`.
extension RituRasaThemeContext on BuildContext {
  RituRasaThemeExtension get rituTheme =>
      Theme.of(this).extension<RituRasaThemeExtension>() ??
      RituRasaThemeExtension.light();
}
