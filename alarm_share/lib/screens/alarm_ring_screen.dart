import 'package:alarm_share/models/alarm.dart';
import 'package:flutter/material.dart';
import 'package:alarm_share/services/alarm_service.dart';

class AlarmRingScreen extends StatefulWidget {
  final String alarmId;

  const AlarmRingScreen({Key? key, required this.alarmId}) : super(key: key);

  @override
  _AlarmRingScreenState createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  @override
  void initState() {
    super.initState();
    _playAlarm();
  }

  Future<void> _playAlarm() async {
    final alarms = await AlarmService.getAlarms();
    final alarm = alarms.firstWhere(
      (a) => a.id == widget.alarmId,
      orElse: () => Alarm(
        id: 'default',
        time: TimeOfDay.now(),
        repeatDays: List.filled(7, false),
        sound: 'alarm_sound_1',
        isEnabled: false,
      ),
    );
    await AlarmService.playAlarmSound(alarm.sound);
  }

  @override
  void dispose() {
    AlarmService.stopAlarm(widget.alarmId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '알람',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        AlarmService.stopAlarm(widget.alarmId);
                        Navigator.of(context).pop();
                      },
                      child: const Text('중지'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        AlarmService.snoozeAlarm(widget.alarmId);
                        Navigator.of(context).pop();
                      },
                      child: const Text('스누즈'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}