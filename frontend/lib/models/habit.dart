class Habit {
  final String id;
  String title;
  String? description;
  int xp; // XP per check-in
  Set<DateTime> checkins; // store dates at midnight

  Habit({
    required this.id,
    required this.title,
    this.description,
    this.xp = 5,
    Set<DateTime>? checkins,
  }) : checkins = checkins ?? {};

  bool isCheckedToday(DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    return checkins.contains(t);
  }

  void toggleToday(DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    if (checkins.contains(t)) {
      checkins.remove(t);
    } else {
      checkins.add(t);
    }
  }
}
