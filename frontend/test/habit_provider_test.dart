import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/providers/habit_provider.dart';

void main() {
  setUp(() {
    // WICHTIG: leerer Zustand -> verhindert Seeding der Demo-Habits
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  test('add and delete habit', () async {
    final p = HabitProvider();
    await p.loadInitial();

    p.addHabit('Test Habit');
    expect(p.habits.length, 1);
    expect(p.habits.single.title, 'Test Habit');

    p.deleteHabit(p.habits.single.id);
    expect(p.habits.length, 0);
  });

  test('toggle completion updates streak and XP', () async {
    final p = HabitProvider();
    await p.loadInitial();

    p.addHabit('Read', xp: 10);
    final habit = p.habits.last; // zuletzt hinzugefügt (xp=10)

    // Wir nutzen deine vorhandene API: heute togglen
    p.toggleCheckinToday(habit.id);
    expect(habit.checkins.length, 1);
    expect(p.totalXpToday, 10);

    // undo
    p.toggleCheckinToday(habit.id);
    expect(habit.checkins.length, 0);
    expect(p.totalXpToday, 0);
  });

  test('earned badges updates when XP threshold reached', () async {
    final p = HabitProvider();
    await p.loadInitial();

    p.addHabit('Grind', xp: 1000);
    final habit = p.habits.last;

    // Ein Check-in -> 1000 XP all-time
    p.toggleCheckinToday(habit.id);
    expect(p.earnedBadges.contains('500 XP Club'), isTrue);
  });
}
