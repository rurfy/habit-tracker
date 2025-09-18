// File: frontend/lib/widgets/habit_tile.dart
// Habit list tile: shows title/XP and a checkbox for today's completion; toggles via HabitProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  const HabitTile({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final provider =
        context.read<HabitProvider>(); // mutate via provider (no rebuild here)
    final todayChecked = habit
        .isCheckedToday(DateTime.now()); // consider a Clock for testability

    return ListTile(
      title: Text(habit.title),
      subtitle: Text('XP: ${habit.xp}'),
      trailing: Checkbox(
        value: todayChecked,
        onChanged: (_) => provider.toggleCheckinToday(habit.id),
      ),
      // onTap: () => provider.toggleCheckinToday(habit.id), // optional: tap whole row
    );
  }
}
