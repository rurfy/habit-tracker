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

  int get totalCheckins => checkins.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'xp': xp,
        'checkins': checkins.map((d) => d.toIso8601String()).toList(),
      };

  static Habit fromJson(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      xp: map['xp'] as int? ?? 5,
      checkins: ((map['checkins'] as List<dynamic>? ?? [])).map((s) {
        final dt = DateTime.parse(s as String);
        return DateTime(dt.year, dt.month, dt.day);
      }).toSet(),
    );
  }
}
