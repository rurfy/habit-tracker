import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';

class HabitProvider extends ChangeNotifier {
  final List<Habit> _habits = [];
  final _storage = StorageService();

  List<Habit> get habits => List.unmodifiable(_habits);

  Future<void> loadInitial() async {
    final raw = await _storage.load();
    if (raw != null) {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => Habit.fromJson(e as Map<String, dynamic>))
          .toList();
      _habits
        ..clear()
        ..addAll(list);
    } else {
      // seed demo
      _habits.addAll([
        Habit(id: '1', title: '10 min reading', xp: 5),
        Habit(id: '2', title: 'Short workout', xp: 8),
      ]);
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final data = jsonEncode(_habits.map((h) => h.toJson()).toList());
    await _storage.save(data);
  }

  void addHabit(String title, {String? description, int xp = 5}) {
    final id = Random().nextInt(1 << 31).toString();
    _habits.add(Habit(id: id, title: title, description: description, xp: xp));
    _persist();
    notifyListeners();
  }

  void editHabit(String id, {String? title, String? description, int? xp}) {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;
    final h = _habits[idx];
    _habits[idx] = Habit(
      id: h.id,
      title: title ?? h.title,
      description: description ?? h.description,
      xp: xp ?? h.xp,
      checkins: h.checkins,
    );
    _persist();
    notifyListeners();
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    _persist();
    notifyListeners();
  }

  void toggleCheckinToday(String id) {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;
    _habits[idx].toggleToday(DateTime.now());
    _persist();
    notifyListeners();
  }

  void toggleHabitCompletion(Habit habit, DateTime date) {
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx == -1) return;

    final day = DateTime(date.year, date.month, date.day);
    if (_habits[idx].checkins.contains(day)) {
      _habits[idx].checkins.remove(day);
    } else {
      _habits[idx].checkins.add(day);
    }

    _persist();
    notifyListeners();
  }

  int get totalXpToday {
    final today = DateTime.now();
    return _habits.fold(
        0, (sum, h) => sum + (h.isCheckedToday(today) ? h.xp : 0));
  }

  int get totalXpAllTime =>
      _habits.fold(0, (sum, h) => sum + h.xp * h.checkins.length);

  int get level => (totalXpAllTime ~/ 100) + 1;

  int streakFor(Habit h) {
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final d = DateTime(day.year, day.month, day.day)
          .subtract(Duration(days: streak));
      if (h.checkins.contains(d)) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }

  List<String> get earnedBadges {
    final badges = <String>[];
    final longestStreak = _habits.fold<int>(
        0, (maxS, h) => maxS > streakFor(h) ? maxS : streakFor(h));
    if (longestStreak >= 7) badges.add('7-Day Streak');
    if (totalXpAllTime >= 500) badges.add('500 XP Club');
    final totalCheckins = _habits.fold<int>(0, (s, h) => s + h.checkins.length);
    if (totalCheckins >= 30) badges.add('30 Check-ins');
    return badges;
  }

  /// Anzahl erledigter Check-ins der letzten 7 Tage (inkl. heute), Index 0 = 6 Tage zurück, 6 = heute
  List<int> last7DaysCounts() {
    final today = DateTime.now();
    List<int> counts = List.filled(7, 0);
    for (final h in _habits) {
      for (final d in h.checkins) {
        final diff = today.difference(DateTime(d.year, d.month, d.day)).inDays;
        if (diff >= 0 && diff < 7) {
          counts[6 - diff] += 1;
        }
      }
    }
    return counts;
  }

  List<int> lastNDaysCounts(int n) {
    final today = DateTime.now();
    final counts = List<int>.filled(n, 0);
    for (final h in _habits) {
      for (final d in h.checkins) {
        final dd = DateTime(d.year, d.month, d.day);
        final diff = today.difference(dd).inDays;
        if (diff >= 0 && diff < n) {
          counts[n - 1 - diff] += 1;
        }
      }
    }
    return counts;
  }

  /// XP pro Tag für die letzten [n] Tage, Index 0 = ältester Tag, n-1 = heute
  List<int> dailyXpCounts(int n) {
    final today = DateTime.now();
    final counts = List<int>.filled(n, 0);
    for (final h in _habits) {
      for (final d in h.checkins) {
        final dd = DateTime(d.year, d.month, d.day);
        final diff = today.difference(dd).inDays;
        if (diff >= 0 && diff < n) {
          counts[n - 1 - diff] += h.xp;
        }
      }
    }
    return counts;
  }

  /// Top-N Gewohnheiten nach Check-in-Anzahl (absteigend)
  List<MapEntry<Habit, int>> topHabitsByCheckins(int topN) {
    final entries = _habits.map((h) => MapEntry(h, h.checkins.length)).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(topN).toList();
  }

  String exportJson() {
    return jsonEncode(_habits.map((h) => h.toJson()).toList());
  }

  Future<void> importJson(String json) async {
    final list = (jsonDecode(json) as List)
        .map((e) => Habit.fromJson(e as Map<String, dynamic>))
        .toList();
    _habits
      ..clear()
      ..addAll(list);
    await _persist();
    notifyListeners();
  }
}
