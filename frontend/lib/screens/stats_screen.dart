// File: frontend/lib/screens/stats_screen.dart
// Stats UI: XP line, Check-ins bar, and Top 5 list; supports 7d/30d ranges.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int range = 7; // days shown: 7 or 30

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HabitProvider>();

    final xpData = p.dailyXpCounts(range);
    final chkData = p.lastNDaysCounts(range);
    final labels = _labels(range);
    final top5 = p.topHabitsByCheckins(5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'XP'),
            Tab(text: 'Check-ins'),
            Tab(text: 'Top 5'),
          ],
        ),
        actions: [
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('7d'),
            selected: range == 7,
            onSelected: (_) => setState(() => range = 7),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('30d'),
            selected: range == 30,
            onSelected: (_) => setState(() => range = 30),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level: ${p.level}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('Total XP: ${p.totalXpAllTime}'),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  // XP (line)
                  _buildXpLineChart(xpData, labels),

                  // Check-ins (bars)
                  _buildCheckinsBar(chkData, labels),

                  // Top 5 (horizontal bars)
                  _buildTopHabits(top5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXpLineChart(List<int> data, List<String> labels) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[i], style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i].toDouble()),
            ),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(), // subtle fill
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinsBar(List<int> data, List<String> labels) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[i], style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: data[i].toDouble(), width: 12)],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHabits(List<MapEntry<dynamic, int>> top5) {
    if (top5.isEmpty) {
      return const Center(child: Text('No data yet'));
    }
    // Simple horizontal bars with a relative width
    final maxVal = top5
        .map((e) => e.value)
        .fold<int>(0, (m, v) => v > m ? v : m)
        .toDouble()
        .clamp(1, 9999);
    return ListView.separated(
      itemCount: top5.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final item = top5[i];
        final ratio = (item.value / maxVal).clamp(0, 1);
        return Row(
          children: [
            SizedBox(width: 40, child: Text('${i + 1}.')),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio.toDouble(),
                    child: Container(
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${item.key.title} (${item.value})'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<String> _labels(int n) {
    final now = DateTime.now();
    final days = List<DateTime>.generate(
        n, (i) => now.subtract(Duration(days: n - 1 - i)));
    // Weekday abbreviations (currently DE locale: Mo–So)
    const short = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return days.map((d) => short[d.weekday - 1]).toList();
  }
}
