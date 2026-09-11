import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';

/// Floating Pill Bottom Navigation Bar (White Theme Equivalent)
/// Matches the reference design with:
/// - Floating rounded stadium capsule
/// - 5 tabs with Home in the center (index 2)
/// - Active pill expansion with animated icon & label
/// - Smooth haptic feedback and pure white theme styling
class FloatingPillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const FloatingPillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    final isCompact = theme.isCompact;

    return Container(
      margin: EdgeInsets.only(
        left: isCompact ? 8 : 12,
        right: isCompact ? 8 : 12,
        bottom: isCompact ? 10 : 14,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 4 : 6,
        vertical: isCompact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: theme.navBarBackground,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: theme.navBarBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: theme.navBarShadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: GNav(
        selectedIndex: currentIndex,
        onTabChange: onTabSelected,
        haptic: true,
        tabBorderRadius: 28,
        gap: isCompact ? 3 : 4,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 7 : 10,
          vertical: isCompact ? 7 : 8,
        ),
        tabBackgroundColor: theme.navBarActivePill,
        activeColor: theme.navBarActiveContent,
        color: theme.navBarInactiveContent,
        iconSize: isCompact ? 18 : 20,
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 240),
        textStyle: GoogleFonts.outfit(
          fontSize: isCompact ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: theme.navBarActiveContent,
        ),
        tabs: const [
          GButton(
            icon: Icons.restaurant_rounded,
            text: 'Eat',
          ),
          GButton(
            icon: Icons.kitchen_outlined,
            text: 'Kitchen',
          ),
          GButton(
            icon: Icons.home_rounded,
            text: 'Home',
          ),
          GButton(
            icon: Icons.shopping_bag_outlined,
            text: 'Cart',
          ),
          GButton(
            icon: Icons.person_outline_rounded,
            text: 'Profile',
          ),
        ],
      ),
    );
  }
}
