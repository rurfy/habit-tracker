// File: frontend/lib/screens/home_screen.dart
// Home: lists habits (empty state + dismiss to delete/edit), quick theme/stats/settings, and add new habit.

import 'package:flutter/material.dart';
import 'package:levelup_habits/models/habit.dart';
import 'package:levelup_habits/screens/settings_screen.dart';
import 'package:levelup_habits/services/notifier.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/habit_tile.dart';
import 'stats_screen.dart';
import 'new_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.timePicker});

  // For tests: injectable time picker (defaults to showTimePicker).
  final Future<TimeOfDay?> Function(BuildContext ctx, TimeOfDay initial)?
      timePicker;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LevelUp Habits'),
        actions: [
          IconButton(
            tooltip: 'Theme',
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
          IconButton(
            tooltip: 'Stats',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(child: Text('XP today: ${provider.totalXpToday}')),
          ),
        ],
      ),

      // Empty state vs. list
      body: habits.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_circle_outlined, size: 72),
                    const SizedBox(height: 12),
                    Text('Noch keine Habits',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('Starte mit deinem ersten Habit und sammle XP!'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Ersten Habit anlegen'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const NewHabitScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final h = provider.habits[index];

                return Dismissible(
                  key: ValueKey(h.id),

                  // Swipe L→R: delete
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  // Swipe R→L: edit
                  secondaryBackground: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),

                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Confirm delete
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete habit?'),
                          content: Text('Really delete "${h.title}"?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (!context.mounted) return false;
                      if (ok == true) {
                        context.read<HabitProvider>().deleteHabit(h.id);
                      }
                      return ok ?? false;
                    } else {
                      // Edit dialog
                      final notifier = context.read<Notifier>();
                      _openEditDialog(context, h, notifier);
                      return false;
                    }
                  },

                  child: HabitTile(habit: h),
                );
              },
            ),

      // Create new habit
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewHabitScreen()),
          );
        },
        label: const Text('New Habit'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _openEditDialog(BuildContext context, Habit h, Notifier notifier) {
    TimeOfDay? reminder; // per-habit reminder time (nullable)
    final titleCtrl = TextEditingController(text: h.title);
    final xpCtrl = TextEditingController(text: '${h.xp}');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        // Local state for the dialog (reminder time)
        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            return AlertDialog(
              title: const Text('Edit habit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: xpCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'XP'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        reminder == null
                            ? 'No reminder'
                            : 'Reminder: ${reminder!.format(dialogCtx)}',
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          // Allow injecting a custom time picker (tests)
                          final pickFn = timePicker ??
                              ((ctx, initial) => showTimePicker(
                                  context: ctx, initialTime: initial));
                          final picked = await pickFn(
                              dialogCtx, reminder ?? TimeOfDay.now());
                          if (!dialogCtx.mounted) return;
                          if (picked != null) {
                            setState(() => reminder = picked);
                          }
                        },
                        child: const Text('Pick time'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final xpVal = int.tryParse(xpCtrl.text) ?? h.xp;

                    // Read providers with the dialog context.
                    final habitProv = dialogCtx.read<HabitProvider>();

                    // 1) Update model immediately (sync)
                    habitProv.editHabit(h.id, title: title, xp: xpVal);

                    // 2) Close dialog
                    if (!dialogCtx.mounted) return;
                    Navigator.of(dialogCtx).pop(true);

                    // 3) Schedule/cancel notification asynchronously (non-blocking)
                    // ignore: unawaited_futures
                    (() async {
                      final notifId = h.id.hashCode;
                      if (reminder != null) {
                        await notifier.scheduleDaily(
                          id: notifId,
                          hour: reminder!.hour,
                          minute: reminder!.minute,
                          title: title.isEmpty ? h.title : title,
                        );
                      } else {
                        await notifier.cancel(notifId);
                      }
                    })();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
