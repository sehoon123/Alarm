import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alarm_share/models/alarm.dart';
import 'package:alarm_share/services/alarm_service.dart';
import 'package:just_audio/just_audio.dart'; // For sound preview

class AlarmSettingsScreen extends StatefulWidget {
  final Alarm? alarm;

  const AlarmSettingsScreen({super.key, this.alarm});

  @override
  _AlarmSettingsScreenState createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  DateTime _selectedTime = DateTime.now();
  List<bool> _selectedDays = List.filled(7, false);
  final List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  double _volume = 0.5;
  bool _vibration = true;
  String _selectedSound = '비모';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _selectedTime =
          DateTime(0, 0, 0, widget.alarm!.time.hour, widget.alarm!.time.minute);
      _selectedDays = List.from(widget.alarm!.repeatDays);
      _selectedSound = widget.alarm!.sound;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getSoundDisplayName() {
    if (_selectedSound.isEmpty) return '비모';
    if (_selectedSound == '비모') return '비모';
    // Map built-in sounds to friendly names
    if (_selectedSound == 'assets/sounds/alarm_sound_1.mp3')
      return '기본 알람 사운드 1';
    if (_selectedSound == 'assets/sounds/alarm_sound_2.mp3')
      return '기본 알람 사운드 2';
    // For custom sounds, display the file name
    return _selectedSound.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소', style: TextStyle(color: Colors.purple)),
        ),
        title: Text(widget.alarm != null ? '알람 수정' : '알람 설정'),
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text('저장', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: _selectedTime,
              onDateTimeChanged: (DateTime newDateTime) {
                setState(() {
                  _selectedTime = newDateTime;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('반복', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    return ChoiceChip(
                      label: Text(
                        _weekdays[index],
                        style: TextStyle(
                          color: _selectedDays[index]
                              ? Colors.white
                              : Colors.purple, // Text color based on selection
                        ),
                      ),
                      selected: _selectedDays[index],
                      selectedColor: Colors.purple,
                      backgroundColor: Colors.grey[300], // Unselected color
                      showCheckmark: false, // Hide the checkmark
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedDays[index] = selected;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('사운드'),
                  trailing: Text(_getSoundDisplayName()),
                  onTap: _selectSound,
                ),
                ListTile(
                  title: const Text('볼륨'),
                  subtitle: Slider(
                    value: _volume,
                    onChanged: (double value) {
                      setState(() {
                        _volume = value;
                      });
                    },
                    min: 0,
                    max: 1,
                    divisions: 10,
                  ),
                ),
                ListTile(
                  title: const Text('진동'),
                  trailing: Switch(
                    value: _vibration,
                    onChanged: (bool value) {
                      setState(() {
                        _vibration = value;
                      });
                    },
                    activeColor: Colors.purple,
                  ),
                ),
                ListTile(
                  title: const Text('미리 듣기'),
                  onTap: _previewSound,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveAlarm() async {
    if (_selectedSound.isEmpty) {
      _selectedSound = '비모';
    }

    Alarm newAlarm = Alarm(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      time: TimeOfDay.fromDateTime(_selectedTime),
      repeatDays: _selectedDays,
      sound: _selectedSound,
      isEnabled: widget.alarm?.isEnabled ?? true,
    );

    if (widget.alarm != null) {
      await AlarmService.updateAlarm(newAlarm.id, newAlarm);
    } else {
      await AlarmService.saveAlarm(newAlarm);
    }

    AlarmService.scheduleAlarm(
      newAlarm,
    );

    Navigator.pop(context, newAlarm); // Pass the updated alarm back
  }

  void _selectSound() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('비모'),
                onTap: () {
                  setState(() {
                    _selectedSound = '비모';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('기본 알람 사운드 1'),
                onTap: () {
                  setState(() {
                    _selectedSound = 'assets/sounds/alarm_sound_1.mp3';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('기본 알람 사운드 2'),
                onTap: () {
                  setState(() {
                    _selectedSound = 'assets/sounds/alarm_sound_2.mp3';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('커스텀 사운드 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickCustomSound();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickCustomSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedSound = result.files.single.path!;
      });
    }
  }

  void _previewSound() async {
    try {
      if (_selectedSound == '비모') {
        // Play default '비모' sound
        await _audioPlayer.setAsset('assets/sounds/default_bimo.mp3');
      } else if (_selectedSound.startsWith('assets/')) {
        // Play built-in sound from assets
        await _audioPlayer.setAsset(_selectedSound);
      } else {
        // Play custom sound from file path
        await _audioPlayer.setFilePath(_selectedSound);
      }
      _audioPlayer.setVolume(_volume);
      _audioPlayer.play();
    } catch (e) {
      // Handle error (e.g., file not found)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사운드 재생에 실패했습니다: $e')),
      );
    }
  }
}
