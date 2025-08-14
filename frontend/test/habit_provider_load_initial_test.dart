// test/habit_provider_load_initial_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/providers/habit_provider.dart';

void main() {
  test('seeds demo habits when storage is empty', () async {
    SharedPreferences.setMockInitialValues({}); // kein Key -> seed
    final p = HabitProvider();
    await p.loadInitial();
    expect(p.habits.length, 2);
  });

  test('does not seed when habits key exists', () async {
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'}); // leer, aber key existiert
    final p = HabitProvider();
    await p.loadInitial();
    expect(p.habits.length, 0);
  });
}
