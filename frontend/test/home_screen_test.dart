// File: frontend/test/home_screen_test.dart
// Smoke test: HomeScreen builds and shows the app title.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen renders and shows title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HabitProvider(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('LevelUp Habits'), findsOneWidget);
  });
}
