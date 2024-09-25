import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm_share/models/my_alarm_settings.dart';
import 'package:alarm_share/services/selected_days_service.dart';
import 'package:flutter/material.dart';

class ExampleAlarmEditScreen extends StatefulWidget {
  final MyAlarmSettings? myAlarmSettings;

  const ExampleAlarmEditScreen({
    Key? key,
    this.myAlarmSettings,
  }) : super(key: key);

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  bool loading = false;

  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  List<bool> selectedDays = List.generate(7, (_) => false);

  @override
  void initState() {
    super.initState();
    creating = widget.myAlarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/sounds/marimba.mp3';
    } else {
      selectedDateTime = widget.myAlarmSettings!.alarmSettings.dateTime;
      loopAudio = widget.myAlarmSettings!.alarmSettings.loopAudio;
      vibrate = widget.myAlarmSettings!.alarmSettings.vibrate;
      volume = widget.myAlarmSettings!.alarmSettings.volume;
      assetAudio = widget.myAlarmSettings!.alarmSettings.assetAudioPath;
      // 요일 선택 초기화
      // selectedDays = widget.alarmSettings!.selectedDays ?? List.generate(7, (_) => false);
    }
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case 2:
        return 'After tomorrow';
      default:
        return 'In $difference days';
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> setPeriodicAlarms(MyAlarmSettings myAlarmSettings) async {
    // 기존 알람 삭제
    await Alarm.stop(myAlarmSettings.alarmSettings.id);

    // 새로운 알람 설정
    final newAlarmSettings = myAlarmSettings.alarmSettings.copyWith(
      dateTime: myAlarmSettings.alarmSettings.dateTime,
    );

    await Alarm.set(alarmSettings: newAlarmSettings);

    // selectedDays 저장
    await SelectedDaysService.saveSelectedDays(newAlarmSettings.id, myAlarmSettings.selectedDays);

    print('알람 설정됨: ID=${newAlarmSettings.id}, 시간=${newAlarmSettings.dateTime}, 선택된 요일=${myAlarmSettings.selectedDays}');
  }

  AlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
        : widget.myAlarmSettings!.alarmSettings.id;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle: 'Alarm example',
      notificationBody: 'Your alarm ($id) is ringing',
      enableNotificationOnKill: Platform.isIOS,
      notificationActionSettings: const NotificationActionSettings(
        hasStopButton: true,
        stopButtonText: 'Stop the alarm',
      ),
      // selectedDays: selectedDays,
    );
    return alarmSettings;
  }

  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);
    final alarmSettings = buildAlarmSettings();
    setPeriodicAlarms(MyAlarmSettings(alarmSettings: alarmSettings, selectedDays: selectedDays)).then((_) {
      if (mounted) Navigator.pop(context, true);
      setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: saveAlarm,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                        'Save',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.blueAccent),
                      ),
              ),
            ],
          ),
          Text(
            getDay(),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
          ),
          RawMaterialButton(
            onPressed: pickTime,
            fillColor: Colors.grey[200],
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                TimeOfDay.fromDateTime(selectedDateTime).format(context),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Colors.blueAccent),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final days = ['월', '화', '수', '목', '금', '토', '일'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDays[index] = !selectedDays[index];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: selectedDays[index]
                        ? Colors.blueAccent
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: selectedDays[index] ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loop alarm audio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: loopAudio,
                onChanged: (value) => setState(() => loopAudio = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibrate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: vibrate,
                onChanged: (value) => setState(() => vibrate = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sound',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: assetAudio,
                items: const [
                  DropdownMenuItem<String>(
                    value: 'assets/sounds/marimba.mp3',
                    child: Text('Marimba'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/sounds/nokia.mp3',
                    child: Text('Nokia'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/sounds/mozart.mp3',
                    child: Text('Mozart'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/sounds/star_wars.mp3',
                    child: Text('Star Wars'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/sounds/one_piece.mp3',
                    child: Text('One Piece'),
                  ),
                ],
                onChanged: (value) => setState(() => assetAudio = value!),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom volume',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: volume != null,
                onChanged: (value) =>
                    setState(() => volume = value ? 0.5 : null),
              ),
            ],
          ),
          SizedBox(
            height: 30,
            child: volume != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        volume! > 0.7
                            ? Icons.volume_up_rounded
                            : volume! > 0.1
                                ? Icons.volume_down_rounded
                                : Icons.volume_mute_rounded,
                      ),
                      Expanded(
                        child: Slider(
                          value: volume!,
                          onChanged: (value) {
                            setState(() => volume = value);
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          // 요일 선택 체크리스트 추가
        ],
      ),
    );
  }
}
