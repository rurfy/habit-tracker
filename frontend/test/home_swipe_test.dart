// File: frontend/test/home_swipe_test.dart
// Swipe gestures on HomeScreen: right → delete (with confirm), left → edit & save.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:levelup_habits/providers/habit_provider.dart';
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
    // SharedPreferences mock so the provider can load without real storage
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

    // Swipe right (startToEnd) → delete dialog
    await tester.drag(find.text('To Delete'), const Offset(500, 0));
    await tester.pumpAndSettle();

    // Confirm
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

    // Swipe left (endToStart) → edit dialog
    await tester.drag(find.text('Old Title'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Update title and save
    await tester.enterText(find.byType(TextField).first, 'New Title');
    await tester.tap(find.text('Save'));
    await tester.pump(); // one frame
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    // Dialog closed
    expect(find.byType(AlertDialog), findsNothing);

    // Verify the ListTile title (not the TextField)
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
