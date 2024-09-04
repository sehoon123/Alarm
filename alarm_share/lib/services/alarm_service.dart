import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm_share/models/alarm.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmService {
  static const String _alarmsKey = 'alarms';
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<List<Alarm>> getAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString(_alarmsKey);
    if (alarmsJson == null) {
      return [];
    }
    final List<dynamic> alarmsList = jsonDecode(alarmsJson);
    return alarmsList.map((alarmMap) => Alarm.fromJson(alarmMap)).toList();
  }

  static Future<void> saveAlarm(Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();
    List<Alarm> alarms = await getAlarms();
    alarms.add(alarm);
    await prefs.setString(
        _alarmsKey, jsonEncode(alarms.map((a) => a.toJson()).toList()));
  }

  static Future<void> updateAlarm(String id, Alarm updatedAlarm) async {
    final prefs = await SharedPreferences.getInstance();
    List<Alarm> alarms = await getAlarms();
    alarms =
        alarms.map((alarm) => alarm.id == id ? updatedAlarm : alarm).toList();
    await prefs.setString(
        _alarmsKey, jsonEncode(alarms.map((a) => a.toJson()).toList()));
  }

  static Future<void> scheduleAlarm(Alarm alarm) async {
    // Schedule the alarm using FlutterLocalNotificationsPlugin or another service
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      DateTime.now().add(const Duration(seconds: 10)), // example time for demo
      tz.local,
    );
    await _notificationsPlugin.zonedSchedule(
      int.parse(alarm.id),
      '알람',
      '알람이 울립니다!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: '알람 알림 채널',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAlarm(String id) async {
    await _notificationsPlugin.cancel(int.parse(id));
  }
}
