// File: frontend/test/stats_toggle_test.dart
// StatsScreen: simple smoke test for 7d/30d range toggle.

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

  testWidgets('Stats range toggle 7/30 renders', (tester) async {
    final p = HabitProvider();
    await p.loadInitial();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: p,
        child: const MaterialApp(home: StatsScreen()),
      ),
    );

    expect(find.text('7d'), findsOneWidget);
    expect(find.text('30d'), findsOneWidget);

    // Toggle to 30d; no crash is sufficient for this smoke test
    await tester.tap(find.text('30d'));
    await tester.pumpAndSettle();

    expect(find.text('30d'), findsOneWidget);
  });
}
