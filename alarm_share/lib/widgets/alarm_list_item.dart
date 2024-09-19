import 'package:alarm_share/services/alarm_service.dart';
import 'package:flutter/material.dart';
import 'package:alarm_share/models/alarm.dart';
import 'package:alarm_share/screens/alarm_settings_screen.dart';

class AlarmListItem extends StatelessWidget {
  final Alarm alarm;
  final Function(Alarm, bool) onToggle;
  final Function(Alarm) onUpdate;
  final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  AlarmListItem({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Upper part with alarm title, time, and switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900], // Dark gray background for the top
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: ListTile(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlarmSettingsScreen(alarm: alarm),
                  ),
                );

                if (result != null && result is Alarm) {
                  try {
                    await AlarmService.updateAlarm(result.id, result);
                    if (result.isEnabled) {
                      await AlarmService.scheduleAlarm(result);
                    } else {
                      await AlarmService.cancelAlarm(result.id);
                    }
                    await onUpdate(result);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('알람이 저장되었습니다.')),
                    );
                  } catch (e) {
                    debugPrint('Error updating alarm: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('알람 업데이트 중 오류가 발생했습니다: $e')),
                    );
                  }
                }
              },
              title: Text(
                alarm.id == 1
                    ? '기상 알람 설정'
                    : '취침 알람 설정', // Updated to match the screenshot
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm.time.format(context),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: alarm.isEnabled,
                    onChanged: (value) {
                      onToggle(alarm, value);
                    },
                  ),
                ],
              ),
            ),
          ),
          // Lower part with the repeat days in light gray
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                // Array for Korean weekdays ['월', '화', '수', '목', '금', '토', '일']
                final List<String> weekdays = [
                  '월',
                  '화',
                  '수',
                  '목',
                  '금',
                  '토',
                  '일'
                ];
                final isSelected =
                    alarm.repeatDays[index]; // Check if the day is selected

                return Text(
                  weekdays[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.black
                        : Colors.grey[
                            200], // Bright for selected, gray for non-selected
                  ),
                );
              }),
            ),
          ),
        ],
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
