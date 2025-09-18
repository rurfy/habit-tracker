// File: frontend/test/settings_screen_test.dart
// Navigates to Settings from Home and toggles the daily summary switch.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/providers/habit_provider.dart';
import 'package:levelup_habits/providers/settings_provider.dart';
import 'package:levelup_habits/providers/theme_provider.dart';
import 'package:levelup_habits/screens/home_screen.dart';
import 'package:levelup_habits/screens/settings_screen.dart';
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
  setUp(() => SharedPreferences.setMockInitialValues({'habits_v1': '[]'}));

  testWidgets('Open Settings and toggle daily summary', (tester) async {
    final p = HabitProvider();
    await p.loadInitial();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: p),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          Provider<Notifier>.value(value: DummyNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Open Settings from the AppBar action
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    // Toggle the daily summary switch (second SwitchListTile)
    final tile = find.byType(SwitchListTile).at(1);
    expect(tile, findsOneWidget);
    await tester.tap(tile);
    await tester.pump();

    // Switch should have toggled to true
    final switchWidget = tester.widget<SwitchListTile>(tile);
    expect(switchWidget.value, isTrue);
  });
}
