// alarm_list_screen.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:alarm/alarm.dart';
import 'package:alarm_share/models/my_alarm_settings.dart';
import 'package:alarm_share/screens/edit_alarm.dart';
import 'package:alarm_share/screens/ring.dart';
import 'package:alarm_share/screens/shortcut_button.dart';
import 'package:alarm_share/services/permissions_service.dart';
import 'package:alarm_share/services/selected_days_service.dart';
import 'package:alarm_share/widgets/tile.dart';
import 'package:flutter/material.dart';
import 'package:alarm_share/widgets/notification_card.dart'; // Import the NotificationCard widget
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  _AlarmListScreenState createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  List<MyAlarmSettings> myAlarms = []; // 여기에 myAlarms 변수를 추가합니다.

  static StreamSubscription<AlarmSettings>? ringSubscription;
  static StreamSubscription<int>? updateSubscription;

  @override
  void initState() {
    super.initState();
    if (Alarm.android) {
      AlarmPermissions.checkAndroidNotificationPermission();
      AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
    }
    loadAlarms();
    ringSubscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
    updateSubscription ??= Alarm.updateStream.stream.listen((_) {
      loadAlarms();
    });
  }

  Future<void> loadAlarms() async {
    final alarmSettings = Alarm.getAlarms();
    alarmSettings.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);

    List<MyAlarmSettings> loadedAlarms = [];
    for (var alarm in alarmSettings) {
      List<bool> selectedDays = await SelectedDaysService.loadSelectedDays(alarm.id) ?? List.generate(7, (_) => false);
      loadedAlarms.add(MyAlarmSettings(alarmSettings: alarm, selectedDays: selectedDays));
    }

    setState(() {
      myAlarms = loadedAlarms; // 여기서 myAlarms를 업데이트합니다.
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            ExampleAlarmRingScreen(alarmSettings: alarmSettings),
      ),
    );
    loadAlarms();
  }

  Future<void> navigateToAlarmScreen(MyAlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ExampleAlarmEditScreen(myAlarmSettings: settings),
        );
      },
    );

    if (res != null && res == true) loadAlarms();
  }

  @override
  void dispose() {
    ringSubscription?.cancel();
    updateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '홈',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '보유코인: 100',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 190,
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      NotificationCard(
                          text: '202X년 XX월 X주차 응모 마감까지\nOO시간 OO분 OO초',
                          clicked: () {}),
                      NotificationCard(
                          text: '또 다른 알림 텍스트 예시 1', clicked: () {}),
                      NotificationCard(
                          text: '또 다른 알림 텍스트 예시 2', clicked: () {}),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8.0,
                      width: _currentPage == index ? 16.0 : 8.0,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index ? Colors.purple : Colors.grey,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
              child: myAlarms.isEmpty
                  ? const Center(child: Text('알람이 설정되지 않았습니다'))
                  : ListView.separated(
                      itemCount: myAlarms.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return ExampleAlarmTile(
                          key: Key(myAlarms[index].alarmSettings.id.toString()),
                          title: TimeOfDay(
                            hour: myAlarms[index].alarmSettings.dateTime.hour,
                            minute: myAlarms[index].alarmSettings.dateTime.minute,
                          ).format(context),
                          selectedDays: myAlarms[index].selectedDays,
                          onPressed: () => navigateToAlarmScreen(myAlarms[index]),
                        );
                      },
                    )),
          NotificationCard(text: '알림 텍스트 예시 1', clicked: () {}),
        ],
      ),
    );
  }
}
