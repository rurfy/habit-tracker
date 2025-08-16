import 'notification_service.dart';

/// Abstraktion, damit wir in Tests mocken können.
abstract class Notifier {
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
  });

  Future<void> cancel(int id);
}

/// Produktiv-Implementierung, ruft die statischen Methoden auf.
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
