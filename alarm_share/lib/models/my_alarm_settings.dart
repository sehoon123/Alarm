import 'package:alarm/alarm.dart';

class MyAlarmSettings {
  final AlarmSettings alarmSettings;
  final List<bool> selectedDays;

  MyAlarmSettings({
    required this.alarmSettings,
    required this.selectedDays,
  });

  MyAlarmSettings copyWith({
    AlarmSettings? alarmSettings,
    List<bool>? selectedDays,
  }) {
    return MyAlarmSettings(
      alarmSettings: alarmSettings ?? this.alarmSettings,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
}