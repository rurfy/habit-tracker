import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/screens/new_habit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('requires title before saving', (WidgetTester tester) async {
    final p = HabitProvider();
    await p.loadInitial();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: p,
        child: const MaterialApp(home: NewHabitScreen()),
      ),
    );

    // Direkt speichern ohne Titel -> Validator greift
    await tester.tap(find.text('Save'));
    await tester.pump(); // zeigt Fehlermeldung
    expect(find.textContaining('Please enter a title'), findsOneWidget);

    // Titel setzen -> Save klappt
    await tester.enterText(find.byType(TextFormField).first, 'Meditation');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(p.habits.any((h) => h.title == 'Meditation'), isTrue);
  });

  testWidgets('Add habit via NewHabitScreen', (WidgetTester tester) async {
    final p = HabitProvider();
    await p.loadInitial();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: p,
        child: const MaterialApp(home: NewHabitScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Workout');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(p.habits.any((h) => h.title == 'Workout'), true);
  });
}
