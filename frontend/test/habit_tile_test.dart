// File: frontend/test/habit_tile_test.dart
// Widget test: tapping the checkbox on HabitTile toggles today's completion.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/widgets/habit_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(
        {}); // start empty → demo seeding may occur in loadInitial
  });

  testWidgets('Tapping checkbox toggles completion',
      (WidgetTester tester) async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Read', xp: 10);
    final habit = p.habits.first;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: p,
        child: MaterialApp(
          home: Scaffold(
            body: HabitTile(habit: habit),
          ),
        ),
      ),
    );

    expect(habit.checkins.length, 0);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(habit.checkins.length, 1);
  });
}
