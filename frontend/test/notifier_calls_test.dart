// File: frontend/test/notifier_calls_test.dart
// Ensures editing a habit and picking a time triggers Notifier.scheduleDaily with expected args.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/providers/theme_provider.dart';
import 'package:levelup_habits/providers/settings_provider.dart';
import 'package:levelup_habits/screens/home_screen.dart';
import 'package:levelup_habits/services/notifier.dart';

/// Mock for the Notifier interface (named params supported via mocktail)
class NotifierMock extends Mock implements Notifier {}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  testWidgets('edit + pick time ⇒ scheduleDaily called', (tester) async {
    final notif = NotifierMock();

    // Stub scheduleDaily to return Future<void>
    when(() => notif.scheduleDaily(
          id: any(named: 'id'),
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
          title: any(named: 'title'),
        )).thenAnswer((_) async {});
    // cancel may be called in other flows; stub for completeness
    when(() => notif.cancel(any())).thenAnswer((_) async {});

    // Prepare provider with one habit
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('EditMe');

    // Deterministic time picker: always returns 20:15
    Future<TimeOfDay?> fakePicker(BuildContext _, TimeOfDay __) async =>
        const TimeOfDay(hour: 20, minute: 15);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider.value(value: p),
          Provider<Notifier>.value(value: notif),
        ],
        child: MaterialApp(home: HomeScreen(timePicker: fakePicker)),
      ),
    );

    // Swipe left on 'EditMe' to open the edit dialog
    expect(find.text('EditMe'), findsOneWidget);
    await tester.drag(find.text('EditMe'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Pick time (fakePicker returns 20:15)
    await tester.tap(find.text('Pick time'));
    await tester.pumpAndSettle();

    // Save → should trigger scheduleDaily(...)
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(() => notif.scheduleDaily(
          id: any(named: 'id'),
          hour: 20,
          minute: 15,
          title: 'EditMe',
        )).called(1);
  });
}
