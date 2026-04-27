import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: InitializationSettings(
        android: android,
        iOS: ios,
      ),
    );
  }

  static Future<void> scheduleReminder({
    required int id,
    required String contactName,
    required String note,
    required DateTime scheduledDate,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminders',
        'Follow-up Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      // Convert to UTC for storage-like consistency, then to current local for scheduling
      final utcDate = scheduledDate.toUtc();
      final localDate = tz.TZDateTime.from(utcDate, tz.local);

      await _plugin.zonedSchedule(
        id: id,
        title: 'Follow up with $contactName',
        body: note.isNotEmpty ? note : 'Time to reconnect!',
        scheduledDate: localDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Log or handle scheduling failure
    }
  }

  static Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id: id);
  }
}
