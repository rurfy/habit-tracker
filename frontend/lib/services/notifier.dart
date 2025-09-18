// File: frontend/lib/services/notifier.dart
// Notification abstraction (mockable in tests); impl delegates to NotificationService.

import 'notification_service.dart';

/// Abstraction for scheduling/canceling notifications (easy to mock in tests).
abstract class Notifier {
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
  });

  Future<void> cancel(int id);
}

/// Production implementation: forwards to NotificationService.
class LocalNotifier implements Notifier {
  @override
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
  }) {
    return NotificationService.scheduleDaily(
      id: id,
      hour: hour,
      minute: minute,
      title: title,
    );
  }

  @override
  Future<void> cancel(int id) => NotificationService.cancel(id);
}
