import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/screens/home_screen.dart';
import 'package:levelup_habits/services/notifier.dart';

/// Einfacher No-Op Notifier für Widget-Tests
class DummyNotifier implements Notifier {
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
  }) async {}
}

void main() {
  setUp(() {
    // shared_preferences mocken, damit der Provider laden kann
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  testWidgets('Swipe right deletes habit after confirm', (tester) async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('To Delete');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: p),
          Provider<Notifier>.value(value: DummyNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('To Delete'), findsOneWidget);

    // Swipe nach rechts (startToEnd) -> Delete-Dialog
    await tester.drag(find.text('To Delete'), const Offset(500, 0));
    await tester.pumpAndSettle();

    // Bestätigen
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('To Delete'), findsNothing);
  });

  testWidgets('Swipe left opens edit dialog and saves changes', (tester) async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Old Title');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: p),
          Provider<Notifier>.value(value: DummyNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Swipe nach links (endToStart) -> Edit-Dialog
    await tester.drag(find.text('Old Title'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Titel anpassen + speichern
    await tester.enterText(find.byType(TextField).first, 'New Title');
    await tester.tap(find.text('Save'));
    await tester.pump(); // ein Frame
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    // Dialog sollte geschlossen sein
    expect(find.byType(AlertDialog), findsNothing);

    // Spezifisch den ListTile-Titel prüfen (nicht das TextField)
    final listTileWithNewTitle = find.byWidgetPredicate((w) {
      if (w is ListTile) {
        final t = w.title;
        return t is Text && t.data == 'New Title';
      }
      return false;
    });

    expect(listTileWithNewTitle, findsOneWidget);
    expect(find.byType(EditableText), findsNothing);
  });
}
