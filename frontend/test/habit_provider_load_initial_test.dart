// File: frontend/test/habit_provider_load_initial_test.dart
// HabitProvider: seeds demo data when storage is empty; skips seeding if key exists.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/providers/habit_provider.dart';

void main() {
  test('seeds demo habits when storage is empty', () async {
    SharedPreferences.setMockInitialValues({}); // no key → seed demo data
    final p = HabitProvider();
    await p.loadInitial();
    expect(p.habits.length, 2);
  });

  test('does not seed when habits key exists', () async {
    SharedPreferences.setMockInitialValues(
      {'habits_v1': '[]'}, // key present (empty list) → no seeding
    );
    final p = HabitProvider();
    await p.loadInitial();
    expect(p.habits.length, 0);
  });
}
