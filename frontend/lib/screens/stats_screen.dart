import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HabitProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level: ${p.level}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Total XP: ${p.totalXpAllTime}'),
            const SizedBox(height: 8),
            Text('Badges: ${p.earnedBadges.isEmpty ? '—' : p.earnedBadges.join(', ')}'),
            const SizedBox(height: 16),
            const Text('Current Streaks:'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: p.habits.length,
                itemBuilder: (_, i) {
                  final h = p.habits[i];
                  return ListTile(
                    title: Text(h.title),
                    trailing: Text('${p.streakFor(h)} day(s)'),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
