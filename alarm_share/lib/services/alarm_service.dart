import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:alarm_share/models/alarm.dart';
import 'notification_service.dart'; // NotificationService 임포트

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _alarmsKey = 'alarms';

  static Future<void> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_alarmsKey)) {
      await prefs.setString(_alarmsKey, jsonEncode([]));
    }
  }

  static Future<List<Alarm>> getAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String alarmsJson = prefs.getString(_alarmsKey) ?? '[]';
    final List<dynamic> alarmsList = jsonDecode(alarmsJson);
    return alarmsList.map((alarmMap) => Alarm.fromJson(alarmMap)).toList();
  }

  static Future<void> saveAlarm(Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();
    List<Alarm> alarms = await getAlarms();
    alarms.add(alarm);
    await prefs.setString(
        _alarmsKey, jsonEncode(alarms.map((a) => a.toJson()).toList()));
    if (alarm.isEnabled) {
      await scheduleAlarm(alarm);
    }
  }

  static Future<void> scheduleAlarm(Alarm alarm) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(alarm.id),
        '알람',
        '알람이 울립니다!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel_01', // 생성한 채널 ID 사용
            'Alarms',
            channelDescription: '알람 알림 채널',
            importance: Importance.high,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('alarm_sound_1'),
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling alarm: $e');
    }
  }

  static Future<void> cancelAlarm(String id) async {
    await _notificationsPlugin.cancel(int.parse(id));
    final prefs = await SharedPreferences.getInstance();
    List<Alarm> alarms = await getAlarms();
    alarms.removeWhere((alarm) => alarm.id == id);
    await prefs.setString(
        _alarmsKey, jsonEncode(alarms.map((a) => a.toJson()).toList()));
  }

  static Future<void> updateAlarm(String id, Alarm updatedAlarm) async {
    await cancelAlarm(id);
    await saveAlarm(updatedAlarm);
    if (updatedAlarm.isEnabled) {
      await scheduleAlarm(updatedAlarm);
    }
  }

  static Future<void> printStoredAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String alarmsJson = prefs.getString(_alarmsKey) ?? '[]';
    debugPrint('Stored alarms in SharedPreferences:');
    debugPrint(alarmsJson);

    final List<dynamic> alarmsList = jsonDecode(alarmsJson);
    final alarms =
        alarmsList.map((alarmMap) => Alarm.fromJson(alarmMap)).toList();

    for (var alarm in alarms) {
      debugPrint('Alarm ID: ${alarm.id}');
      debugPrint('Time: ${alarm.time}');
      debugPrint('Repeat Days: ${alarm.repeatDays}');
      debugPrint('Sound: ${alarm.sound}');
      debugPrint('Enabled: ${alarm.isEnabled}');
      debugPrint('---');
    }
  }
}
