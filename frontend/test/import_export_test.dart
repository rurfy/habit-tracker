// File: frontend/test/import_export_test.dart
// Export/import roundtrip using shared_preferences mock and two providers.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/providers/habit_provider.dart';

void main() {
  setUp(() {
    // Start with empty SharedPreferences so loadInitial() doesn't seed.
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  test('export/import roundtrip', () async {
    // p1: create habit and export
    final p1 = HabitProvider();
    await p1.loadInitial();
    p1.addHabit('Exported', xp: 9);
    final exported = p1.exportJson();

    // Note: p1.addHabit() persisted to SharedPreferences.
    // Reset storage so p2 starts empty:
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});

    // p2: start empty, then import
    final p2 = HabitProvider();
    await p2.loadInitial();
    expect(p2.habits, isEmpty);

    await p2.importJson(exported);

    expect(p2.habits.length, 1);
    expect(p2.habits.first.title, 'Exported');
    expect(p2.habits.first.xp, 9);
  });
}
