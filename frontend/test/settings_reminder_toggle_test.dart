// File: frontend/test/settings_reminder_toggle_test.dart
// SettingsScreen: toggling the reminder switch flips SettingsProvider.dailySummaryEnabled.

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

  // Pump SettingsScreen with required providers.
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HabitProvider()..loadInitial()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Finder for the reminder switch by title text containing "reminder".
  Finder reminderSwitch() {
    return find.byWidgetPredicate((w) =>
        w is SwitchListTile &&
        w.title is Text &&
        ((w.title as Text).data ?? '').toLowerCase().contains('reminder'));
  }

  testWidgets('Toggling reminder switch updates SettingsProvider',
      (tester) async {
    await pump(tester);

    // Read provider value before toggling
    final ctx = tester.element(find.byType(SettingsScreen));
    final settings = Provider.of<SettingsProvider>(ctx, listen: false);
    final before = settings.dailySummaryEnabled;

    final sw = reminderSwitch();
    expect(sw, findsOneWidget);

    await tester.tap(sw);
    await tester.pump();

    // Expect flipped value
    expect(settings.dailySummaryEnabled, isNot(equals(before)));
  });
}
