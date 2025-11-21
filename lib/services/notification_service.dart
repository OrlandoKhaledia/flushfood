import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/models/inventory_item.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone database
    tzdata.initializeTimeZones();
    // Try to use the platform DateTime timezone name as an IANA name,
    // but fall back to UTC if it's not available in the tz database.
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: (details) async {
      // Handle notification tapped
    });

    // Request iOS permissions explicitly
    _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleExpiryNotificationsForItem(InventoryItem item) async {
    // Cancel any existing for safety
    await cancelNotificationsForItem(item.id);

    // Schedule notifications 7, 3 and 1 day before expiry if in future
    final days = [7, 3, 1];
    for (final d in days) {
      final scheduled = item.expiryDate.subtract(Duration(days: d));
      if (scheduled.isAfter(DateTime.now())) {
        final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);
        await _plugin.zonedSchedule(
          _idFor(item.id, d),
          'Expiring: ${item.name}',
          'Expires in $d day${d == 1 ? '' : 's'}',
          tzScheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'expiry_channel',
              'Expiry Notifications',
              channelDescription: 'Notifications for expiring items',
              importance: Importance.defaultImportance,
            ),
          ),
          // Newer plugin versions require an Android schedule mode parameter.
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          // Keep scheduling simple and platform-appropriate; matching only time component.
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }

  Future<void> cancelNotificationsForItem(String itemId) async {
    for (final d in [7, 3, 1]) {
      await _plugin.cancel(_idFor(itemId, d));
    }
  }

  int _idFor(String id, int days) {
    // Create numeric id from hash
    return id.hashCode ^ days;
  }
}
