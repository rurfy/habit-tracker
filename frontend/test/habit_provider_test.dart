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

  test('editHabit updates title, description and xp', () async {
    final p = HabitProvider();
    await p.loadInitial();

    p.addHabit('Old', description: 'desc');
    final id = p.habits.single.id;

    p.editHabit(id, title: 'New', description: 'newdesc', xp: 9);

    final h = p.habits.single;
    expect(h.title, 'New');
    expect(h.description, 'newdesc');
    expect(h.xp, 9);
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

  test('awards 500 XP Club', () async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Grind', xp: 500);
    final id = p.habits.single.id;
    p.toggleCheckinToday(id);
    expect(p.earnedBadges.contains('500 XP Club'), isTrue);
  });

  test('awards 7-Day Streak', () async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Streaky', xp: 1);
    final h = p.habits.single;
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      h.checkins.add(DateTime(d.year, d.month, d.day));
    }
    expect(p.earnedBadges.contains('7-Day Streak'), isTrue);
  });

  test('awards 30 Check-ins', () async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Daily', xp: 1);
    final h = p.habits.single;
    for (int i = 0; i < 30; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      h.checkins.add(DateTime(d.year, d.month, d.day));
    }
    expect(p.earnedBadges.contains('30 Check-ins'), isTrue);
  });
}
