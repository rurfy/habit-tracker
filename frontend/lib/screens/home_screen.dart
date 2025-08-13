import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_tile.dart';
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Text('XP today: ${provider.totalXpToday}'),
            ),
          ),
        ],
      ),
      body: habits.isEmpty
          ? const Center(child: Text('No habits yet. Add your first one!'))
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (_, i) => HabitTile(habit: habits[i]),
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
}
