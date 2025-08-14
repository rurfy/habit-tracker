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
}
