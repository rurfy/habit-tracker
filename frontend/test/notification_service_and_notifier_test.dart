// File: frontend/test/notification_service_and_notifier_test.dart
// SettingsScreen: toggling the reminder switch updates SettingsProvider (EN/DE label tolerant).

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
    SharedPreferences.setMockInitialValues({'habits_v1': '[]'}); // start empty
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

  // Finder for the reminder switch (matches EN/DE titles).
  Finder reminderSwitch() {
    return find.byWidgetPredicate((w) {
      if (w is SwitchListTile) {
        final t = (w.title is Text)
            ? ((w.title as Text).data ?? '').toLowerCase()
            : '';
        return t.contains('reminder') || t.contains('erinner');
      }
      return false;
    });
  }

  testWidgets('Toggling reminder switch updates SettingsProvider',
      (tester) async {
    await pump(tester);

    final ctx = tester.element(find.byType(SettingsScreen));
    final settings = Provider.of<SettingsProvider>(ctx, listen: false);
    final before = settings.dailySummaryEnabled;

    final sw = reminderSwitch();
    expect(sw, findsOneWidget);

    await tester.tap(sw);
    await tester.pump();

    expect(settings.dailySummaryEnabled, isNot(equals(before)));
  });
}
