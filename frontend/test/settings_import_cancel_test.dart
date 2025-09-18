// File: frontend/test/settings_import_cancel_test.dart
// Settings import: opening the dialog and tapping Cancel leaves provider state unchanged.

import 'package:flutter/material.dart';
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

  // Finder for the import ListTile (matches by title text).
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

  Future<void> pump(WidgetTester tester, HabitProvider p) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: p),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Import dialog cancel leaves provider unchanged', (tester) async {
    final p = HabitProvider();
    await p.loadInitial();
    p.addHabit('Original');
    final before = p.habits.length;

    await pump(tester, p);

    final importTile = findImportTile();
    expect(importTile, findsOneWidget);
    await tester.tap(importTile);
    await tester.pumpAndSettle();

    // Tap dialog Cancel
    final cancelBtn = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(TextButton, 'Cancel'),
    );
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    expect(p.habits.length, before);
    expect(p.habits.first.title, 'Original');
  });
}
