// File: frontend/lib/services/notification_service.dart
// Local notifications: initialize plugin/timezone and schedule a daily reminder.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class NotificationService {
  // Single plugin instance used across the app.
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Time zone setup (best effort) so scheduled times align with the device locale.
    tz.initializeTimeZones();
    final locName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(locName));

    // Basic platform init (icons/channels are kept simple for this demo).
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
  }

  static Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    String? body,
  }) async {
    // Skip unsupported targets: web and non-mobile platforms.
    if (kIsWeb) return; // web does not support local notifications
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    // Next occurrence of the specified time (today or tomorrow).
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id, // use a stable ID per reminder so it can be updated/canceled
      title,
      body ?? 'Time for $title',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habits',
          'Habits',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily at time
    );
  }

  // Cancel a single scheduled notification by ID.
  static Future<void> cancel(int id) => _plugin.cancel(id);
}
