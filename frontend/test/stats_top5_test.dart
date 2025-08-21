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

  Future<void> pumpWithProvider(WidgetTester tester, HabitProvider p) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: p),
        ],
        child: const MaterialApp(home: StatsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Top 5 tab shows habits sorted by check-ins', (tester) async {
    final p = HabitProvider();
    await p.loadInitial();

    DateTime d(int daysAgo) {
      final now = DateTime.now().subtract(Duration(days: daysAgo));
      return DateTime(now.year, now.month, now.day);
    }

    // Create 6 habits with different check-in counts so we can assert Top 5
    p.addHabit('Alpha');
    p.habits[0].checkins.addAll({d(0), d(1), d(2)}); // 3
    p.addHabit('Bravo');
    p.habits[1].checkins.addAll({d(0)}); // 1
    p.addHabit('Charlie');
    p.habits[2].checkins.addAll({d(0), d(2)}); // 2
    p.addHabit('Delta');
    p.habits[3].checkins
        .addAll({d(0), d(1), d(2), d(3), d(4), d(5), d(6), d(7)}); // 8
    p.addHabit('Echo');
    p.habits[4].checkins
        .addAll({d(0), d(1), d(2), d(3), d(4), d(5), d(6)}); // 7
    p.addHabit('Foxtrot');
    p.habits[5].checkins.addAll({d(0), d(1), d(2), d(3), d(4)}); // 5

    await pumpWithProvider(tester, p);

    // Switch to "Top 5" tab
    await tester.tap(find.text('Top 5'));
    await tester.pumpAndSettle();

    // Expect top habits appear with counts in the label text, e.g. 'Delta (8)'
    expect(find.textContaining('Delta (8)'), findsOneWidget);
    expect(find.textContaining('Echo (7)'), findsOneWidget);
    expect(find.textContaining('Foxtrot (5)'), findsOneWidget);

    // Bravo (1) should be 6th -> not listed
    expect(find.textContaining('Bravo (1)'), findsNothing);
  });

  testWidgets('Switching 7d/30d still builds charts without crash',
      (tester) async {
    final p = HabitProvider();
    await p.loadInitial();

    // Seed a single habit with ~20 days of check-ins to exercise 30d range
    p.addHabit('Runner');
    for (int i = 0; i < 20; i++) {
      final now = DateTime.now().subtract(Duration(days: i));
      p.habits.single.checkins.add(DateTime(now.year, now.month, now.day));
    }

    await pumpWithProvider(tester, p);

    expect(find.text('7d'), findsOneWidget);
    expect(find.text('30d'), findsOneWidget);

    // Toggle to 30d and make sure the view renders
    await tester.tap(find.text('30d'));
    await tester.pumpAndSettle();

    // Ensure the three tabs are still there (charts built)
    expect(find.text('XP'), findsOneWidget);
    expect(find.text('Check-ins'), findsOneWidget);
    expect(find.text('Top 5'), findsOneWidget);
  });
}
