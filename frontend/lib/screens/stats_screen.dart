import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // <-- NEU
import '../providers/habit_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HabitProvider>();
    final data = p.last7DaysCounts();
    final labels = _weekdayLabels();

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
            const Text('Last 7 days (check-ins)'),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i > 6) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(labels[i], style: const TextStyle(fontSize: 11)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [BarChartRodData(toY: data[i].toDouble(), width: 14)],
                    );
                  }),
                ),
              ),
            ),
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
            ),
          ],
        ),
      ),
    );
  }

  List<String> _weekdayLabels() {
    final now = DateTime.now();
    final days = List<DateTime>.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    const short = ['Mo','Di','Mi','Do','Fr','Sa','So'];
    return days.map((d) => short[d.weekday - 1]).toList();
  }
}
