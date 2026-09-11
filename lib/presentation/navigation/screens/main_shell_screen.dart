import 'package:flutter/material.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/presentation/cart/screens/cart_screen.dart';
import 'package:riturasa/presentation/eat/screens/eat_screen.dart';
import 'package:riturasa/presentation/home/screens/home_screen.dart';
import 'package:riturasa/presentation/kitchen/screens/kitchen_screen.dart';
import 'package:riturasa/presentation/navigation/widgets/floating_pill_nav_bar.dart';
import 'package:riturasa/presentation/profile/screens/profile_screen.dart';

/// Controller to allow child screens (like HomeScreen quick actions) to switch tabs.
class MainShellScope extends InheritedWidget {
  final void Function(int index) switchTab;

  const MainShellScope({
    super.key,
    required this.switchTab,
    required super.child,
  });

  static MainShellScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  @override
  bool updateShouldNotify(covariant MainShellScope oldWidget) => false;
}

/// Root navigation shell that hosts the 5 core application modules
/// with the Home Screen placed centrally at index 2.
class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 2, // Home screen is centrally positioned
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    EatScreen(), // Index 0: Core recommendation & recipes
    KitchenScreen(), // Index 1: User pantry & inventory
    HomeScreen(), // Index 2: Central cycle status & daily progress
    CartScreen(), // Index 3: Smart grocery shopping list
    ProfileScreen(), // Index 4: Settings & personalization
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.rituTheme;

    return MainShellScope(
      switchTab: _onTabSelected,
      child: Scaffold(
        backgroundColor: theme.screenBackground,
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.02),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _screens[_currentIndex],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: FloatingPillNavBar(
            currentIndex: _currentIndex,
            onTabSelected: _onTabSelected,
          ),
        ),
      ),
    );
  }
}
