// File: frontend/lib/models/habit.dart
// Habit model: title/description, XP per check-in, and a set of normalized (midnight) check-in dates.

class Habit {
  final String id;
  String title;
  String? description;
  int xp; // XP per check-in
  Set<DateTime> checkins; // normalized to midnight (YYYY-MM-DD)

  Habit({
    required this.id,
    required this.title,
    this.description,
    this.xp = 5,
    Set<DateTime>? checkins,
  }) : checkins = checkins ?? {};

  /// True if a check-in exists for [today] (date-only).
  bool isCheckedToday(DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    return checkins.contains(t);
  }

  /// Toggle the check-in for [today] (date-only).
  void toggleToday(DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    if (checkins.contains(t)) {
      checkins.remove(t);
    } else {
      checkins.add(t);
    }
  }

  int get totalCheckins => checkins.length;

  /// JSON (dates serialized as ISO strings).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'xp': xp,
        'checkins': checkins.map((d) => d.toIso8601String()).toList(),
      };

  /// Parse from JSON, normalizing dates to midnight.
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
