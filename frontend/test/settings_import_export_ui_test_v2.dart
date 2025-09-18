// File: frontend/test/settings_import_export_ui_test_v2.dart
// Settings UI: export copies JSON to clipboard; import updates provider; dark mode toggles ThemeProvider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/providers/settings_provider.dart';
import 'package:levelup_habits/providers/theme_provider.dart';
import 'package:levelup_habits/screens/settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'});
  });

  // Find ListTile by title text containing "export"
  Finder findExportTile() {
    return find.byWidgetPredicate((w) {
      if (w is ListTile) {
        final title = w.title;
        if (title is Text) {
          final t = (title.data ?? '').toLowerCase();
          return t.contains('export');
        }
      }
      return false;
    });
  }

  // Find ListTile by title text containing "import"
  Finder findImportTile() {
    return find.byWidgetPredicate((w) {
      if (w is ListTile) {
        final title = w.title;
        if (title is Text) {
          final t = (title.data ?? '').toLowerCase();
          return t.contains('import');
        }
      }
      return false;
    });
  }

  // Find the Dark Mode switch (EN/DE tolerant)
  Finder findDarkModeSwitch() {
    return find.byWidgetPredicate((w) {
      if (w is SwitchListTile) {
        final title = w.title;
        if (title is Text) {
          final t = (title.data ?? '').toLowerCase();
          return t.contains('dark') || t.contains('dunkel');
        }
        return true;
      }
      return false;
    });
  }

  Future<void> pumpSettings(
    WidgetTester tester, {
    required HabitProvider habits,
    required ThemeProvider theme,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: habits),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider.value(value: theme),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Export copies JSON to clipboard', (tester) async {
    final habits = HabitProvider();
    await habits.loadInitial();
    habits.addHabit('Export me', xp: 9);

    final theme = ThemeProvider();
    await pumpSettings(tester, habits: habits, theme: theme);

    // Tap export and assert clipboard got JSON (skip snackbar text)
    final exportTile = findExportTile();
    expect(exportTile, findsOneWidget);
    await tester.tap(exportTile);
    await tester.pumpAndSettle();

    final data = await Clipboard.getData('text/plain');
    expect(data, isNotNull);
    expect(data!.text, isNotEmpty);
    expect(data.text!.trim().startsWith('['), isTrue);
  });

  testWidgets('Import accepts JSON and updates provider', (tester) async {
    // Prepare exported JSON
    final seed = HabitProvider();
    await seed.loadInitial();
    seed.addHabit('Imported', xp: 4);
    final json = seed.exportJson();

    final habits = HabitProvider();
    await habits.loadInitial();
    final beforeLen = habits.habits.length;

    final theme = ThemeProvider();
    await pumpSettings(tester, habits: habits, theme: theme);

    // Open import, paste JSON, confirm
    final importTile = findImportTile();
    expect(importTile, findsOneWidget);
    await tester.tap(importTile);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, json);
    final importBtn = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(TextButton, 'Import'),
    );
    await tester.tap(importBtn);
    await tester.pumpAndSettle();

    expect(
      habits.habits.any((h) => h.title == 'Imported' && h.xp == 4),
      isTrue,
    );
    expect(habits.habits.length >= beforeLen, isTrue);
  });

  testWidgets('Dark Mode switch toggles ThemeProvider.mode', (tester) async {
    final habits = HabitProvider();
    await habits.loadInitial();
    final theme = ThemeProvider();

    await pumpSettings(tester, habits: habits, theme: theme);

    final before = theme.mode;
    final switchFinder = findDarkModeSwitch();
    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pump();

    expect(theme.mode, isNot(equals(before)));
  });
}
