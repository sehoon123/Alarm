import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:alarm_share/models/alarm.dart';
import 'notification_service.dart'; // NotificationService 임포트
import 'package:audioplayers/audioplayers.dart'; // 오디오 재생을 위해 추가

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _alarmsKey = 'alarms';
  static AudioPlayer? _audioPlayer;

  static Future<void> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_alarmsKey)) {
      // 기본 알람 두 개 생성
      Alarm alarm1 = Alarm(
        id: '1',
        time: TimeOfDay(hour: 7, minute: 0),
        repeatDays: List.filled(7, false), // 매일 반복하지 않음
        sound: '비모',
        isEnabled: true,
      );

      Alarm alarm2 = Alarm(
        id: '2',
        time: TimeOfDay(hour: 22, minute: 0),
        repeatDays: List.filled(7, false),
        sound: '비모',
        isEnabled: true,
      );

      List<Alarm> defaultAlarms = [alarm1, alarm2];
      String alarmsJson =
          jsonEncode(defaultAlarms.map((alarm) => alarm.toJson()).toList());
      await prefs.setString(_alarmsKey, alarmsJson);

      // 기본 알람 스케줄링
      for (var alarm in defaultAlarms) {
        await scheduleAlarm(alarm);
      }
    }
  }

  static Future<List<Alarm>> getAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String alarmsJson = prefs.getString(_alarmsKey) ?? '[]';
    final List<dynamic> alarmsList = jsonDecode(alarmsJson);
    return alarmsList.map((alarmMap) => Alarm.fromJson(alarmMap)).toList();
  }

  static Future<void> scheduleAlarm(Alarm alarm) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    try {
      await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
        alarm.id.hashCode,
        '알람',
        '알��이 울립니다!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel_01',
            'Alarms',
            channelDescription: '알람 알림 채널',
            importance: Importance.high,
            priority: Priority.high,
            fullScreenIntent: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: alarm.id,
      );
    } catch (e) {
      debugPrint('Error scheduling alarm: $e');
    }
  }

  static Future<void> saveAlarm(Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();
    List<Alarm> alarms = await getAlarms();
    alarms.add(alarm);
    String alarmsJson =
        jsonEncode(alarms.map((alarm) => alarm.toJson()).toList());
    await prefs.setString(_alarmsKey, alarmsJson);
    await scheduleAlarm(alarm);
  }

  static Future<void> updateAlarm(String id, Alarm updatedAlarm) async {
    final prefs = await SharedPreferences.getInstance();
    List<Alarm> alarms = await getAlarms();
    int index = alarms.indexWhere((alarm) => alarm.id == id);
    if (index != -1) {
      alarms[index] = updatedAlarm;
      String alarmsJson =
          jsonEncode(alarms.map((alarm) => alarm.toJson()).toList());
      await prefs.setString(_alarmsKey, alarmsJson);
      await scheduleAlarm(updatedAlarm);
    }
  }

  static Future<void> cancelAlarm(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<Alarm> alarms = await getAlarms();
    alarms.removeWhere((alarm) => alarm.id == id);
    String alarmsJson =
        jsonEncode(alarms.map((alarm) => alarm.toJson()).toList());
    await prefs.setString(_alarmsKey, alarmsJson);
    await NotificationService.flutterLocalNotificationsPlugin
        .cancel(id.hashCode);
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

  static Future<void> stopAlarm(String id) async {
    try {
      // 1. 알림 취소
      await NotificationService.flutterLocalNotificationsPlugin
          .cancel(id.hashCode);

      // 2. 알람 소리 중지
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        await _audioPlayer!.dispose();
        _audioPlayer = null;
      }

      // 3. 알람 상태 업데이트
      final alarms = await getAlarms();
      final alarmIndex = alarms.indexWhere((alarm) => alarm.id == id);
      if (alarmIndex != -1) {
        final updatedAlarm = alarms[alarmIndex].copyWith(isEnabled: false);
        alarms[alarmIndex] = updatedAlarm;
        await _saveAlarms(alarms);
      }

      debugPrint('알람 $id가 성공적으로 중지되었습니다.');
    } catch (e) {
      debugPrint('알람 중지 중 오류 발생: $e');
    }
  }

  static Future<void> snoozeAlarm(String id) async {
    final alarms = await getAlarms();
    final alarm = alarms.firstWhere(
      (a) => a.id == id,
      orElse: () {
        print('Warning: Alarm with id $id not found. Creating a new one.');
        return Alarm(
          id: id,
          time: TimeOfDay.now(),
          repeatDays: List.filled(7, false),
          sound: '비모',
          isEnabled: true,
        );
      },
    );

    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    final updatedAlarm = alarm.copyWith(
      time: TimeOfDay.fromDateTime(snoozeTime),
      isEnabled: true,
    );
    await updateAlarm(id, updatedAlarm);
    await scheduleAlarm(updatedAlarm);
  }

  static Future<void> playAlarmSound(String sound) async {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();
    }

    // 최신 버전의 audioplayers에서는 setLoopMode 사용
    await _audioPlayer!
        .setSource(AssetSource('assets/sounds/$sound.mp3')); // 올바른 경로로 설정
    await _audioPlayer!.resume(); // 재생 시작
  }

  // 알람 목록을 저장하는 헬퍼 메서드
  static Future<void> _saveAlarms(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = alarms.map((alarm) => alarm.toJson()).toList();
    await prefs.setString(_alarmsKey, jsonEncode(alarmsJson));
  }
}
