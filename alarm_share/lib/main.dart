import 'package:flutter/material.dart';
import 'package:alarm_share/screens/main_screen.dart';
import 'package:alarm_share/services/notification_service.dart';
import 'package:alarm_share/utils/timezone_setup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.initialize();
  TimezoneSetup.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '알람 공유 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}