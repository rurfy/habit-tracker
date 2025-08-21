import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_habits/models/habit.dart';

void main() {
  test('Habit toggleToday / isCheckedToday / totalCheckins', () {
    final h = Habit(id: '1', title: 'Read');
    final today = DateTime.now();

    expect(h.isCheckedToday(today), isFalse);
    h.toggleToday(today);
    expect(h.isCheckedToday(today), isTrue);
    expect(h.totalCheckins, 1);

    // toggle again -> remove
    h.toggleToday(today);
    expect(h.isCheckedToday(today), isFalse);
    expect(h.totalCheckins, 0);

    // add two distinct days
    h.toggleToday(today);
    final yesterday = today.subtract(const Duration(days: 1));
    h.toggleToday(yesterday);
    expect(h.totalCheckins, 2);
  });

  test('Habit toJson / fromJson roundtrip', () {
    final today = DateTime.now();
    final h1 = Habit(
      id: '42',
      title: 'Workout',
      description: 'short',
      xp: 8,
      checkins: {
        DateTime(today.year, today.month, today.day),
      },
    );

    final map = h1.toJson();
    final h2 = Habit.fromJson(map);

    expect(h2.id, '42');
    expect(h2.title, 'Workout');
    expect(h2.description, 'short');
    expect(h2.xp, 8);
    expect(h2.totalCheckins, 1);
    expect(h2.isCheckedToday(today), isTrue);
  });
}
