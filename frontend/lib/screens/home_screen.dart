import 'package:flutter/material.dart';
import 'package:levelup_habits/models/habit.dart';
import 'package:levelup_habits/services/notification_service.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/habit_tile.dart';
import 'stats_screen.dart';
import 'new_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(child: Text('XP today: ${provider.totalXpToday}')),
          ),
        ],
      ),
      body: habits.isEmpty
          ? const Center(child: Text('No habits yet. Add your first one!'))
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final h = provider.habits[index];
                return Dismissible(
                  key: ValueKey(h.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
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
                      _openEditDialog(context, h);
                      return false;
                    }
                  },
                  child: HabitTile(habit: h),
                );
              },
            ),
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

  void _openEditDialog(BuildContext context, Habit h) {
    TimeOfDay? reminder;
    final titleCtrl = TextEditingController(text: h.title);
    final xpCtrl = TextEditingController(text: '${h.xp}');

    showDialog(
      context: context,
      builder: (dialogCtx) {
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
                          final picked = await showTimePicker(
                            context: dialogCtx,
                            initialTime: reminder ?? TimeOfDay.now(),
                          );
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

                    // 1) Model sofort updaten (sync)
                    context
                        .read<HabitProvider>()
                        .editHabit(h.id, title: title, xp: xpVal);

                    // 2) Dialog SOFORT schließen – über den RootNavigator
                    final nav = Navigator.of(dialogCtx, rootNavigator: true);
                    if (!dialogCtx.mounted) return;
                    nav.pop(true);

                    // 3) Notifications asynchron starten (nicht blockieren)
                    //    -> sorgt dafür, dass der Dialog im Test nicht hängen bleibt
                    // ignore: unawaited_futures
                    (() async {
                      final notifId = h.id.hashCode;
                      if (reminder != null) {
                        await NotificationService.scheduleDaily(
                          id: notifId,
                          hour: reminder!.hour,
                          minute: reminder!.minute,
                          title: title.isEmpty ? h.title : title,
                        );
                      } else {
                        await NotificationService.cancel(notifId);
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
