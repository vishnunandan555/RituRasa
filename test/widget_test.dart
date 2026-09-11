import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riturasa/main.dart';
import 'package:riturasa/presentation/navigation/widgets/floating_pill_nav_bar.dart';

import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  testWidgets('App renders Home Screen in center by default and switches between all 5 modules', (WidgetTester tester) async {
    // Provide a standard phone screen size
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: RituRasaApp(),
      ),
    );

    // Initial pump and settling for entry animations
    await tester.pumpAndSettle();

    // Verify Home Screen is active initially (Index 2 - Center)
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Cycle Day'), findsOneWidget);
    expect(find.text('Period'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
    expect(find.text('Peak'), findsOneWidget);
    expect(find.text('Luteal'), findsOneWidget);
    expect(find.text('Ovulation'), findsOneWidget);
    expect(find.text('Next Period'), findsOneWidget);

    // Verify Navigation bar tabs exist
    expect(find.byType(FloatingPillNavBar), findsOneWidget);
    expect(find.byType(GButton), findsNWidgets(5));

    // Tap Kitchen Tab (Index 0)
    await tester.tap(find.byType(GButton).at(0));
    await tester.pumpAndSettle();
    expect(find.text('Kitchen & Pantry'), findsOneWidget);
    expect(find.text('Ragi Flour (Finger Millet)'), findsOneWidget);

    // Tap Nutrition Tab (Index 1)
    await tester.tap(find.byType(GButton).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Daily Nutrition'), findsOneWidget);
    expect(find.text('Energy Consumed'), findsOneWidget);

    // Tap Shopping Tab (Index 3)
    await tester.tap(find.byType(GButton).at(3));
    await tester.pumpAndSettle();
    expect(find.text('Smart Grocery List'), findsOneWidget);

    // Tap Profile Tab (Index 4)
    await tester.tap(find.byType(GButton).at(4));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Ananya Sharma'), findsOneWidget);

    // Tap back to Home Tab (Index 2)
    await tester.tap(find.byType(GButton).at(2));
    await tester.pumpAndSettle();
    expect(find.text('Cycle Day'), findsOneWidget);
  });
}

