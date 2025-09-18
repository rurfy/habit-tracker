// File: frontend/test/app_flow_test.dart
// App flow (happy path): create habit → check in → verify XP via provider → open Stats.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/providers/theme_provider.dart';
import 'package:levelup_habits/providers/settings_provider.dart';
import 'package:levelup_habits/screens/home_screen.dart';
import 'package:levelup_habits/services/notifier.dart';

/// No-op Notifier for widget tests
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
    // Reset shared_preferences mock → no stale seeds/state between tests
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

    // 1) Create a new habit (Extended FAB has visible label "New Habit")
    final fabWithLabel = find.widgetWithText(FloatingActionButton, 'New Habit');
    final fabText = find.text('New Habit'); // fallback for label
    expect(fabWithLabel.evaluate().isNotEmpty || fabText.evaluate().isNotEmpty,
        isTrue);

    await tester.tap(fabText);
    await tester.pumpAndSettle();

    // 2) Enter title (and optional XP) then save
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    // First TextField = Title
    await tester.enterText(textFields.at(0), 'Flow Habit');

    // Second TextField (if present) = XP
    if (textFields.evaluate().length >= 2) {
      await tester.enterText(textFields.at(1), '7');
    }

    // Find a save/confirm button by common labels/types
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

    // New habit is visible
    expect(find.text('Flow Habit'), findsOneWidget);

    // Read XP of the new habit from the provider (dynamic, not hardcoded)
    final habit =
        habitProvider.habits.firstWhere((h) => h.title == 'Flow Habit');
    final xpOfNewHabit = habit.xp;

    // 3) Toggle today's check-in via the tile checkbox
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

    // Provider reflects today's XP total
    expect(habitProvider.totalXpToday, xpOfNewHabit);

    // 4) Open Stats via the AppBar Insights icon
    final statsIcon = find.byIcon(Icons.insights_outlined);
    expect(statsIcon, findsOneWidget);
    await tester.tap(statsIcon);
    await tester.pumpAndSettle();

    // Sanity check: Stats screen shows "Level"
    expect(find.textContaining('Level'), findsWidgets);
  });
}
