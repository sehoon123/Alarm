import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel_01',
      'Alarms',
      description: '알람 알림 채널',
      importance: Importance.high, // 중요도 높음으로 설정
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound_1'), // 확장자 제외
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    // 알람이 울릴 때 수행할 작업을 여기에 추가할 수 있습니다.
  }
}
