import 'package:flutter/material.dart';
import 'package:alarm_share/screens/main_screen.dart';
import 'package:alarm_share/services/notification_service.dart';
import 'package:alarm_share/services/alarm_service.dart';
import 'package:alarm_share/utils/timezone_setup.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await AlarmService.initialize();
  TimezoneSetup.initialize();

  // 알림 권한 요청 추가
  await NotificationService.requestPermissions();

  await AlarmService.printStoredAlarms();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '알람 공유 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}
