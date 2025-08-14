import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // <-- NEU
import '../providers/habit_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int range = 7; // 7 oder 30

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HabitProvider>();
    final data = p.lastNDaysCounts(range);
    final labels = _weekdayLabels(range);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ChoiceChip(
                  label: const Text('7d'),
                  selected: range == 7,
                  onSelected: (_) => setState(() => range = 7)),
              const SizedBox(width: 8),
              ChoiceChip(
                  label: const Text('30d'),
                  selected: range == 30,
                  onSelected: (_) => setState(() => range = 30)),
            ]),
            const SizedBox(height: 12),
            Text('Level: ${p.level}',
                style: Theme.of(context).textTheme.headlineSmall),
            Text('Total XP: ${p.totalXpAllTime}'),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(labels[i],
                                style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    data.length,
                    (i) => BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: data[i].toDouble(), width: 10)
                    ]),
                  ),
                ),
              ),
            ),
            // ... dein Rest (Streak-Liste etc.)
          ],
        ),
      ),
    );
  }

  List<String> _weekdayLabels(int n) {
    final now = DateTime.now();
    final days = List<DateTime>.generate(
        n, (i) => now.subtract(Duration(days: n - 1 - i)));
    const short = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return days.map((d) => short[d.weekday - 1]).toList();
  }
}
