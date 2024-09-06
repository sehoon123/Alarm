import 'package:alarm_share/services/alarm_service.dart';
import 'package:flutter/material.dart';
import 'package:alarm_share/models/alarm.dart';
import 'package:alarm_share/services/notification_service.dart';
import 'package:alarm_share/widgets/notification_carousel.dart';
import 'package:alarm_share/widgets/alarm_list_item.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  _AlarmListScreenState createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> with RouteAware {
  final List<Alarm> _alarms = [
    Alarm(
        id: '1',
        time: const TimeOfDay(hour: 7, minute: 0),
        repeatDays: [true, false, false, false, false, false, false],
        sound: '비모'),
    Alarm(
        id: '2',
        time: const TimeOfDay(hour: 8, minute: 0),
        repeatDays: [false, true, false, false, false, false, false],
        sound: '비모'),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _toggleAlarm(Alarm alarm, bool isEnabled) {
    setState(() {
      alarm.isEnabled = isEnabled;
    });

    AlarmService.updateAlarm(alarm.id, alarm);

    if (isEnabled) {
      AlarmService.scheduleAlarm(alarm);
    } else {
      AlarmService.cancelAlarm(alarm.id);
    }
  }

  void _updateAlarm(Alarm updatedAlarm) {
    setState(() {
      int index = _alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
      if (index != -1) {
        _alarms[index] = updatedAlarm;
      }
    });

    AlarmService.updateAlarm(updatedAlarm.id, updatedAlarm);
  }

  void _testNotification() {
    // 테스트용 알림 생성 및 즉시 표시
    NotificationService.flutterLocalNotificationsPlugin.show(
      0,
      '알림 테스트',
      '이것은 테스트 알림입니다.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: '알람 알림 채널',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
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
          const NotificationCarousel(),
          Expanded(
            child: _alarms.isEmpty
                ? const Center(child: Text('No alarms set'))
                : ListView.builder(
                    itemCount: _alarms.length,
                    itemBuilder: (context, index) {
                      return AlarmListItem(
                        alarm: _alarms[index],
                        onToggle: _toggleAlarm,
                        onUpdate: _updateAlarm,
                      );
                    },
                  ),
          ),
          GestureDetector(
            onTap: _testNotification,
            child: Card(
              margin: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.7),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    '알림 테스트',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
