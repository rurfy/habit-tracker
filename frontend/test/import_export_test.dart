import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/providers/habit_provider.dart';

void main() {
  setUp(() {
    // Leerer Startzustand in SharedPreferences, damit loadInitial() nicht seedet
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  test('export/import roundtrip', () async {
    // p1: Habit anlegen und exportieren
    final p1 = HabitProvider();
    await p1.loadInitial();
    p1.addHabit('Exported', xp: 9);
    final exported = p1.exportJson();

    // ACHTUNG: p1.addHabit() persistiert in SharedPreferences.
    // Für p2 wollen wir einen leeren Start → Storage resetten:
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});

    // p2: leer starten, dann importieren
    final p2 = HabitProvider();
    await p2.loadInitial();
    expect(p2.habits, isEmpty);

    await p2.importJson(exported);

    expect(p2.habits.length, 1);
    expect(p2.habits.first.title, 'Exported');
    expect(p2.habits.first.xp, 9);
  });
}
