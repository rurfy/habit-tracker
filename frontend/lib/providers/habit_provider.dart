import 'dart:math';
import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  final List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);

  void loadInitial() {
    _habits.addAll([
      Habit(id: '1', title: '10 min reading', xp: 5),
      Habit(id: '2', title: 'Short workout', xp: 8),
    ]);
    notifyListeners();
  }

  void addHabit(String title, {String? description, int xp = 5}) {
    final id = Random().nextInt(1 << 31).toString();
    _habits.add(Habit(id: id, title: title, description: description, xp: xp));
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
    notifyListeners();
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  void toggleCheckinToday(String id) {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;
    _habits[idx].toggleToday(DateTime.now());
    notifyListeners();
  }

  int get totalXpToday {
    final today = DateTime.now();
    return _habits.fold(0, (sum, h) => sum + (h.isCheckedToday(today) ? h.xp : 0));
  }
}
