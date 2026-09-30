import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundServiceHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
    );
    _initialized = true;
  }

  static Future<void> showArmedNotification() async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'emergency_armed_channel',
      'Emergency Call Armed Monitor',
      channelDescription:
          'Persistent background monitoring status notification',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: 888,
      title: 'Emergency Call is Armed',
      body: 'Continuous motion monitoring active',
      notificationDetails: notificationDetails,
    );
  }

  static Future<void> cancelArmedNotification() async {
    await init();
    await _notificationsPlugin.cancel(id: 888);
  }
}
