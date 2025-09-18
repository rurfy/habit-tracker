// File: frontend/test/widget_test.dart
// App smoke test: loads HomeScreen via LevelUpApp and adds a habit.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:levelup_habits/main.dart';
import 'package:levelup_habits/providers/habit_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('App loads HomeScreen and adds a habit',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HabitProvider(),
        child: const LevelUpApp(),
      ),
    );

    // Let the FutureBuilder settle
    await tester.pumpAndSettle();

    expect(find.text('LevelUp Habits'), findsOneWidget);

    // New-habit flow
    // Tap FAB (+ icon)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter title
    await tester.enterText(find.byType(TextFormField).first, 'Test Habit');
    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Habit appears?
    expect(find.text('Test Habit'), findsOneWidget);
  });
}
