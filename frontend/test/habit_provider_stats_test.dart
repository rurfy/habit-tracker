// File: frontend/test/habit_provider_stats_test.dart
// HabitProvider stats: daily XP aggregation and Top-N by check-ins.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/providers/habit_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  test('dailyXpCounts sums XP per day', () async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('A'); // default XP = 5
    p.addHabit('B', xp: 10); // XP = 10

    final a = p.habits[0];
    final b = p.habits[1];
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final y = DateTime(
      today.subtract(const Duration(days: 1)).year,
      today.subtract(const Duration(days: 1)).month,
      today.subtract(const Duration(days: 1)).day,
    );

    a.checkins.addAll([t, y]); // A today + yesterday → 5 + 5
    b.checkins.add(t); // B today → 10

    final xp = p.dailyXpCounts(7);
    // Index: 0=oldest … 6=today
    expect(xp[6], 15); // 5 (A) + 10 (B)
    expect(xp[5], 5); // 5 (A)
  });

  test('topHabitsByCheckins returns top 2 sorted', () async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('X');
    p.addHabit('Y');

    final x = p.habits[0];
    final y = p.habits[1];

    final now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day);
    final yest = DateTime(
      now.subtract(const Duration(days: 1)).year,
      now.subtract(const Duration(days: 1)).month,
      now.subtract(const Duration(days: 1)).day,
    );

    x.checkins.addAll([t, yest]); // X: 2
    y.checkins.add(t); // Y: 1

    final top = p.topHabitsByCheckins(2);
    expect(top.first.key.title, 'X');
    expect(top.first.value, 2);
    expect(top.last.key.title, 'Y');
    expect(top.last.value, 1);
  });
}
