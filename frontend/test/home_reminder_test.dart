import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/screens/home_screen.dart';
import 'package:levelup_habits/services/notifier.dart';

class MockNotifier extends Mock implements Notifier {}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  testWidgets('setting a reminder schedules a daily notification',
      (tester) async {
    final notifier = MockNotifier();
    when(() => notifier.scheduleDaily(
          id: any(named: 'id'),
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          title: any(named: 'title'),
        )).thenAnswer((_) async {});
    when(() => notifier.cancel(any())).thenAnswer((_) async {});

    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Test Habit', xp: 5);

    // injiziere Notifier & einen deterministischen timePicker (10:30)
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: p),
          Provider<Notifier>.value(value: notifier),
        ],
        child: MaterialApp(
          home: HomeScreen(
            timePicker: (ctx, initial) async =>
                const TimeOfDay(hour: 10, minute: 30),
          ),
        ),
      ),
    );

    // Swipe left -> Edit-Dialog
    await tester.drag(find.text('Test Habit'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Zeit "wählen" (unser injizierter Picker liefert sofort 10:30)
    await tester.tap(find.text('Pick time'));
    await tester.pump();

    // Speichern (Dialog schließt sofort, Scheduling läuft async)
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);

    verify(() => notifier.scheduleDaily(
          id: any(named: 'id'),
          hour: 10,
          minute: 30,
          title: any(named: 'title'),
        )).called(1);
  });

  testWidgets('no reminder removes existing notification', (tester) async {
    final notifier = MockNotifier();
    when(() => notifier.cancel(any())).thenAnswer((_) async {});
    when(() => notifier.scheduleDaily(
          id: any(named: 'id'),
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          title: any(named: 'title'),
        )).thenAnswer((_) async {});

    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Test Habit', xp: 5);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: p),
          Provider<Notifier>.value(value: notifier),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Swipe left -> Edit-Dialog (keine Zeit setzen)
    await tester.drag(find.text('Test Habit'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    verify(() => notifier.cancel(any())).called(1);
    verifyNever(() => notifier.scheduleDaily(
          id: any(named: 'id'),
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          title: any(named: 'title'),
        ));
  });
}
