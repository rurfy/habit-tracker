import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/providers/habit_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'habits_v1':'[]'}));

  test('export/import roundtrip', () async {
    final p = HabitProvider(); await p.loadInitial();
    p.addHabit('A'); p.addHabit('B', xp: 7);
    final json = p.exportJson();

    final q = HabitProvider(); await q.loadInitial();
    await q.importJson(json);
    expect(q.habits.length, 2);
    expect(q.habits.map((h)=>h.title).toSet(), {'A','B'});
  });
}
