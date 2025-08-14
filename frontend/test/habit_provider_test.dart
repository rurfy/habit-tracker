import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/models/habit.dart';
import 'package:levelup_habits/providers/habit_provider.dart';

void main() {
  // Wichtig: Binding & SharedPreferences-Mock
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('level and streak calculations', () async {
    final p = HabitProvider();
    await p.loadInitial();

    // clear seeded to keep deterministic
    for (final h in List<Habit>.from(p.habits)) {
      p.deleteHabit(h.id);
    }

    p.addHabit('Read', xp: 10);
    final h = p.habits.first;

    final today = DateTime.now();
    h.checkins.addAll([
      DateTime(today.year, today.month, today.day),
      DateTime(today.subtract(const Duration(days: 1)).year, today.subtract(const Duration(days: 1)).month, today.subtract(const Duration(days: 1)).day),
      DateTime(today.subtract(const Duration(days: 2)).year, today.subtract(const Duration(days: 2)).month, today.subtract(const Duration(days: 2)).day),
    ]);

    expect(p.streakFor(h), 3);
    expect(p.totalXpAllTime, 30);
    expect(p.level, 1);
  });
}
