import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
// `latest_all` (not `latest`) so legacy zone aliases some Android devices still
// report — e.g. "Asia/Calcutta", "Asia/Rangoon" — resolve instead of throwing.
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Called with a contact id when the user taps a reminder notification while
  /// the app is running. Set by the app shell.
  static void Function(String contactId)? onReminderTapped;

  static void _handleResponse(NotificationResponse response) {
    final id = response.payload;
    if (id != null && id.isNotEmpty) onReminderTapped?.call(id);
  }

  /// Contact id if the app was cold-started by tapping a reminder, else null.
  static Future<String?> consumeLaunchPayload() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        final id = details?.notificationResponse?.payload;
        if (id != null && id.isNotEmpty) return id;
      }
    } catch (e) {
      debugPrint('NotificationService: launch payload check failed: $e');
    }
    return null;
  }

  static Future<void> init() async {
    // Load the tz database, then pin `tz.local` to the device's actual zone.
    // Without this `tz.local` stays UTC and every scheduled reminder fires at
    // the wrong wall-clock time (and breaks across DST).
    tz_data.initializeTimeZones();
    try {
      final localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone));
    } catch (e) {
      // Fall back to UTC if the platform can't report a zone.
      debugPrint('NotificationService: could not resolve local timezone: $e');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Defer the iOS permission prompt so it can be requested at a sensible
    // moment (when the user first sets a reminder) via [requestPermissions].
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: ios,
      ),
      onDidReceiveNotificationResponse: _handleResponse,
    );
  }

  /// Requests notification permission on iOS 10+ and Android 13+.
  /// Returns true if notifications are allowed. Safe to call repeatedly.
  static Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      // Exact alarms are needed for exactAllowWhileIdle scheduling on Android 12+.
      await android.requestExactAlarmsPermission();
      return granted ?? true;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  static Future<void> scheduleReminder({
    required int id,
    required String contactName,
    required String note,
    required DateTime scheduledDate,
    String? payload,
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
      // Ask for permission at the moment a reminder is actually set. After the
      // first grant/deny this returns the current status without re-prompting.
      final allowed = await requestPermissions();
      if (!allowed) {
        debugPrint('NotificationService: notification permission not granted; '
            'reminder $id stored but not scheduled.');
        return;
      }

      final localDate = tz.TZDateTime.from(scheduledDate.toUtc(), tz.local);

      await _plugin.zonedSchedule(
        id: id,
        title: 'Follow up with $contactName',
        body: note.isNotEmpty ? note : 'Time to reconnect!',
        scheduledDate: localDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('NotificationService: failed to schedule reminder $id: $e');
    }
  }

  static Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id: id);
  }
}
