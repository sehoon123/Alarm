import 'package:flutter/material.dart';

class Alarm {
  final String id;
  TimeOfDay time;
  List<bool> repeatDays;
  String sound;
  bool isEnabled;

  Alarm({
    required this.id,
    required this.time,
    required this.repeatDays,
    required this.sound,
    this.isEnabled = true, // Defaults to enabled
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          List.filled(7, false),
      sound: json['sound'] ?? '비모',
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': time.hour,
      'minute': time.minute,
      'repeatDays': repeatDays,
      'sound': sound,
      'isEnabled': isEnabled,
    };
  }

  Alarm copyWith({
    String? id,
    TimeOfDay? time,
    List<bool>? repeatDays,
    String? sound,
    bool? isEnabled,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      sound: sound ?? this.sound,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
