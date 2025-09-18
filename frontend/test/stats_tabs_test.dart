// File: frontend/test/stats_tabs_test.dart
// StatsScreen tabs: renders all tabs and allows switching the 7d/30d range.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/screens/stats_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  testWidgets('StatsScreen shows tabs and toggles range', (tester) async {
    final p = HabitProvider();
    await p.loadInitial();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: p,
        child: const MaterialApp(home: StatsScreen()),
      ),
    );

    // Tab labels exist
    expect(find.text('XP'), findsOneWidget);
    expect(find.text('Check-ins'), findsOneWidget);
    expect(find.text('Top 5'), findsOneWidget);

    // Switch to 30-day range (ChoiceChip)
    await tester.tap(find.text('30d'));
    await tester.pumpAndSettle();

    // Still renders fine
    expect(find.text('30d'), findsOneWidget);
  });
}
