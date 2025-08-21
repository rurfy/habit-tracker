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

  Finder reminderSwitch() {
    return find.byWidgetPredicate((w) =>
        w is SwitchListTile &&
        w.title is Text &&
        ((w.title as Text).data ?? '').toLowerCase().contains('reminder'));
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
