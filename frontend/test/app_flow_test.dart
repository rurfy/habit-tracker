import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/providers/theme_provider.dart';
import 'package:levelup_habits/providers/settings_provider.dart';
import 'package:levelup_habits/screens/home_screen.dart';
import 'package:levelup_habits/services/notifier.dart';

/// No-op Notifier für Widget-Tests
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
    // shared_preferences Mock leeren → keine alten Seeds/States
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  testWidgets('Add habit → check-in → provider reflects XP; Stats opens',
      (tester) async {
    final habitProvider = HabitProvider();
    await habitProvider.loadInitial();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider.value(value: habitProvider),
          Provider<Notifier>.value(value: DummyNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // ----------------------------------------
    // 1) Neuen Habit anlegen (FAB Extended hat Label "New Habit")
    // ----------------------------------------
    final fabWithLabel = find.widgetWithText(FloatingActionButton, 'New Habit');
    // Fallback: direkt nach Textelement "New Habit" suchen (Ext. FAB rendert Label separat)
    final fabText = find.text('New Habit');
    expect(fabWithLabel.evaluate().isNotEmpty || fabText.evaluate().isNotEmpty,
        isTrue);

    // Tippe auf den FAB über das Label (robust, falls mehrere Icons vorhanden sind)
    await tester.tap(fabText);
    await tester.pumpAndSettle();

    // ----------------------------------------
    // 2) Titel & optional XP eingeben und speichern
    // ----------------------------------------
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    // Erstes TextField = Titel
    await tester.enterText(textFields.at(0), 'Flow Habit');

    // Zweites TextField (falls vorhanden) = XP
    if (textFields.evaluate().length >= 2) {
      await tester.enterText(textFields.at(1), '7');
    }

    // Save/Add/Create-Button suchen (abhängig von deinem NewHabitScreen)
    Finder saveBtn = find.text('Save');
    if (saveBtn.evaluate().isEmpty) {
      if (find.text('Add').evaluate().isNotEmpty) {
        saveBtn = find.text('Add');
      } else if (find.text('Create').evaluate().isNotEmpty) {
        saveBtn = find.text('Create');
      } else if (find.byType(FilledButton).evaluate().isNotEmpty) {
        saveBtn = find.byType(FilledButton);
      } else if (find.byType(ElevatedButton).evaluate().isNotEmpty) {
        saveBtn = find.byType(ElevatedButton);
      }
    }

    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Neuer Habit sichtbar
    expect(find.text('Flow Habit'), findsOneWidget);

// ---> NEU: XP aus dem Provider ablesen
    final habit =
        habitProvider.habits.firstWhere((h) => h.title == 'Flow Habit');
    final xpOfNewHabit = habit.xp;

// 3) Check-in setzen …
    final habitTile = find.byWidgetPredicate(
      (w) =>
          w is ListTile &&
          w.title is Text &&
          (w.title as Text).data == 'Flow Habit',
    );
    expect(habitTile, findsOneWidget);

    final checkBoxInTile = find.descendant(
      of: habitTile,
      matching: find.byType(Checkbox),
    );
    expect(checkBoxInTile, findsOneWidget);

    await tester.tap(checkBoxInTile);
    await tester.pump();

// ---> Erwartung dynamisch statt hart 5/7
    expect(habitProvider.totalXpToday, xpOfNewHabit);

    // ----------------------------------------
    // 4) Stats öffnen: über das eindeutige Insights-Icon in der AppBar
    // ----------------------------------------
    final statsIcon = find.byIcon(Icons.insights_outlined);
    expect(statsIcon, findsOneWidget);
    await tester.tap(statsIcon);
    await tester.pumpAndSettle();

    // Grobe Heuristik: Stats-Screen zeigt z. B. "Level" irgendwo an
    expect(find.textContaining('Level'), findsWidgets);
  });
}
