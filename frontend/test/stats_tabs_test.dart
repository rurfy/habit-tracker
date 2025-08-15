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

    expect(find.text('XP'), findsOneWidget);
    expect(find.text('Check-ins'), findsOneWidget);
    expect(find.text('Top 5'), findsOneWidget);

    await tester.tap(find.text('30d'));
    await tester.pumpAndSettle();
    // Kein Crash -> ok
    expect(find.text('30d'), findsOneWidget);
  });
}
