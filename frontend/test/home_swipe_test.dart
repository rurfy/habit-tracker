import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/screens/home_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  testWidgets('Swipe right deletes habit after confirm', (tester) async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('To Delete', xp: 5);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: p,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('To Delete'), findsOneWidget);

    // Swipe nach rechts (startToEnd)
    await tester.drag(find.text('To Delete'), const Offset(500, 0));
    await tester.pumpAndSettle();

    // Bestätigungsdialog -> Delete
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('To Delete'), findsNothing);
  });

  testWidgets('Swipe left opens edit dialog and saves changes', (tester) async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Old Title', xp: 5);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: p,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Swipe nach links (endToStart)
    await tester.drag(find.text('Old Title'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Dialog: Titel ändern + Save
    await tester.enterText(find.byType(TextField).first, 'New Title');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('New Title'), findsOneWidget);
    expect(find.text('Old Title'), findsNothing);
  });
}
