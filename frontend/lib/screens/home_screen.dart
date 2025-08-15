import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          IconButton(
            tooltip: 'Export',
            icon: const Icon(Icons.download_outlined),
            onPressed: () async {
              final json = context.read<HabitProvider>().exportJson();
              await Clipboard.setData(ClipboardData(text: json));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON in Zwischenablage')),
              );
            },
          ),
          IconButton(
            tooltip: 'Import',
            icon: const Icon(Icons.upload_outlined),
            onPressed: () async {
              final ctrl = TextEditingController();
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Import JSON'),
                  content: TextField(
                    controller: ctrl,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Füge hier dein JSON ein',
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Import')),
                  ],
                ),
              );
              if (!context.mounted) return;
              if (ok == true && ctrl.text.trim().isNotEmpty) {
                await context
                    .read<HabitProvider>()
                    .importJson(ctrl.text.trim());
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import erfolgreich')),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(child: Text('XP today: ${provider.totalXpToday}')),
          ),
        ],
      ),
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
