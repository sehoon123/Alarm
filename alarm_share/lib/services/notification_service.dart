import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    await createNotificationChannel();
  }

  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel2 = AndroidNotificationChannel(
      'alarm_channel_id',
      'Alarm Notifications',
      description: 'This channel is used for alarm notifications.',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel2);
  }

  static Future<void> showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      await _notificationDetails(),
      payload: payLoad,
    );
  }

  static Future<NotificationDetails> _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'alarm_channel_id',
        'Alarm Notifications',
        channelDescription: 'This channel is used for alarm notifications.',
        importance: Importance.max,
      ),
    );
  }

  static void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
  }
}
