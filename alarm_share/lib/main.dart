import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alarm_share/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Alarm.init();

  // 기본 알람 설정
  await setInitialAlarms();

  // Run the app
  runApp(const MyApp());
}

Future<void> setInitialAlarms() async {
  final alarms = await Alarm.getAlarms();
  if (alarms.isEmpty) {
    final now = DateTime.now();
    final alarm1 = AlarmSettings(
      id: 1,
      dateTime: now.add(Duration(hours: 1)),
      assetAudioPath: 'assets/sounds/marimba.mp3',
      notificationTitle: '첫 번째 알람',
      notificationBody: '첫 번째 알람이 울립니다.',
    );
    final alarm2 = AlarmSettings(
      id: 2,
      dateTime: now.add(Duration(hours: 2)),
      assetAudioPath: 'assets/sounds/marimba.mp3',
      notificationTitle: '두 번째 알람',
      notificationBody: '두 번째 알람이 울립니다.',
    );
    await Alarm.set(alarmSettings: alarm1);
    await Alarm.set(alarmSettings: alarm2);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm Sharing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}
