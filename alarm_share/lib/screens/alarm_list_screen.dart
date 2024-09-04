import 'package:flutter/material.dart';
import 'package:alarm_share/models/alarm.dart';
import 'package:alarm_share/screens/alarm_settings_screen.dart';
import 'package:alarm_share/services/alarm_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({super.key});

  @override
  _AlarmListScreenState createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> with RouteAware {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  @override
  void didPopNext() {
    // Called when the user returns to this screen from another
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    List<Alarm> alarms = await AlarmService.getAlarms();
    setState(() {
      _alarms = alarms;
    });
  }

  void _toggleAlarm(Alarm alarm, bool isEnabled) {
    setState(() {
      alarm.isEnabled = isEnabled;
    });

    // Update the alarm in persistent storage and schedule/cancel the alarm notification.
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

    // Persist the updated alarm
    AlarmService.updateAlarm(updatedAlarm.id, updatedAlarm);
  }

  void _scheduleTestAlarm() async {
    final DateTime now = DateTime.now();
    final DateTime scheduledTime = now.add(const Duration(seconds: 5));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID of the notification
      '테스트 알람',
      '5초 후 울리는 알람입니다.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_id',
          '알람 채널',
          channelDescription: '알람 알림을 위한 채널입니다.',
          importance: Importance.max,
          priority: Priority.high,
          ticker: '테스트 알람',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('알람이 5초 후에 울리도록 예약되었습니다: $scheduledTime');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Notification Section with PageView and Indicator
          SizedBox(
            height: 120, // Set height for the notification area
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
                      _buildNotificationCard(
                          '202X년 XX월 X주차 응모 마감까지\nOO시간 OO분 OO초'),
                      _buildNotificationCard('또 다른 알림 텍스트 예시 1'),
                      _buildNotificationCard('또 다른 알림 텍스트 예시 2'),
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
          // List of Alarms
          Expanded(
            child: _alarms.isEmpty
                ? const Center(child: Text('No alarms set'))
                : ListView.builder(
                    itemCount: _alarms.length,
                    itemBuilder: (context, index) {
                      return AlarmListItem(
                        alarm: _alarms[index],
                        onToggle: _toggleAlarm,
                        onUpdate: _updateAlarm, // Pass the update function
                      );
                    },
                  ),
          ),
          // Test Alarm Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _scheduleTestAlarm,
              child: const Text('5초 후 알람 울리기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class AlarmListItem extends StatelessWidget {
  final Alarm alarm;
  final Function(Alarm, bool) onToggle;
  final Function(Alarm) onUpdate; // Add a callback for updating the alarm
  final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  AlarmListItem({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onUpdate, // Receive the update callback
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlarmSettingsScreen(alarm: alarm),
            ),
          );

          if (result != null && result is Alarm) {
            onUpdate(result);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('알람이 저장되었습니다.')),
            );
          }
        },
        title: const Text(
          '알람 설정',
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alarm.time.format(context),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _getRepeatDaysText(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Sound: ${alarm.sound}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Switch(
          value: alarm.isEnabled,
          onChanged: (value) {
            onToggle(alarm, value);
          },
        ),
      ),
    );
  }

  String _getRepeatDaysText() {
    List<String> selectedDays = [];
    for (int i = 0; i < alarm.repeatDays.length; i++) {
      if (alarm.repeatDays[i]) {
        selectedDays.add(weekdays[i]);
      }
    }
    if (selectedDays.isEmpty) {
      return '반복 없음';
    } else if (selectedDays.length == 7) {
      return '매일';
    } else {
      return selectedDays.join(', ');
    }
  }
}
