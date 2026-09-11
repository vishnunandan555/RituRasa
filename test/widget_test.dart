import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riturasa/main.dart';

void main() {
  testWidgets('HomeScreen renders cycle tracker, 4-phase legend, and metric cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RituRasaApp(),
      ),
    );

    // Initial pump and settling for entry animations
    await tester.pumpAndSettle();

    // Verify Date Header
    expect(find.text('Today'), findsOneWidget);

    // Verify Center Dial content
    expect(find.text('Cycle Day'), findsOneWidget);

    // Verify 4 words in the phase legend: Period | Growth | Peak | Luteal
    expect(find.text('Period'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
    expect(find.text('Peak'), findsOneWidget);
    expect(find.text('Luteal'), findsOneWidget);

    // Verify Metric Cards
    expect(find.text('Ovulation'), findsOneWidget);
    expect(find.text('Next Period'), findsOneWidget);
    expect(find.text('Day 14'), findsOneWidget);
  });
}
