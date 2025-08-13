import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  const HabitTile({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HabitProvider>();
    final todayChecked = habit.isCheckedToday(DateTime.now());
    return ListTile(
      title: Text(habit.title),
      subtitle: Text('XP: ${habit.xp}'),
      trailing: Checkbox(
        value: todayChecked,
        onChanged: (_) => provider.toggleCheckinToday(habit.id),
      ),
    );
  }
}
