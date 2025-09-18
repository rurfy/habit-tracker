// File: frontend/test/stats_screen_test.dart
// StatsScreen: renders safely and shows Level/Total XP; provider aggregates last 7 days correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/screens/stats_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('StatsScreen renders without crash', (WidgetTester tester) async {
    final p = HabitProvider();
    await p.loadInitial();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: p,
        child: const MaterialApp(home: StatsScreen()),
      ),
    );
    expect(find.textContaining('Level'), findsOneWidget);
    expect(find.textContaining('Total XP'), findsOneWidget);
  });

  testWidgets('StatsScreen shows Level and XP', (WidgetTester tester) async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Test');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: p,
        child: const MaterialApp(home: StatsScreen()),
      ),
    );

    expect(find.textContaining('Level'), findsOneWidget);
    expect(find.textContaining('Total XP'), findsOneWidget);
  });

  test('last7DaysCounts aggregates check-ins correctly', () async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('A', xp: 1);
    p.addHabit('B', xp: 1);

    final a = p.habits[0];
    final b = p.habits[1];
    final today = DateTime.now();

    // A: today + the day before yesterday
    a.checkins.addAll([
      DateTime(today.year, today.month, today.day),
      DateTime(
        today.subtract(const Duration(days: 2)).year,
        today.subtract(const Duration(days: 2)).month,
        today.subtract(const Duration(days: 2)).day,
      ),
    ]);
    // B: yesterday
    b.checkins.add(
      DateTime(
        today.subtract(const Duration(days: 1)).year,
        today.subtract(const Duration(days: 1)).month,
        today.subtract(const Duration(days: 1)).day,
      ),
    );

    final counts = p.last7DaysCounts();
    expect(counts.length, 7);
    // Index 6 = today, 5 = yesterday, 4 = day before yesterday
    expect(counts[6], 1);
    expect(counts[5], 1);
    expect(counts[4], 1);
  });
}
