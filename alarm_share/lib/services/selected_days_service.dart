import 'package:shared_preferences/shared_preferences.dart';

class SelectedDaysService {
  static Future<void> saveSelectedDays(int alarmId, List<bool> selectedDays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDays_$alarmId', selectedDays.map((e) => e ? '1' : '0').join(''));
  }

  static Future<List<bool>?> loadSelectedDays(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedDays = prefs.getString('selectedDays_$alarmId');
    if (savedDays == null) return null;
    return savedDays.split('').map((e) => e == '1').toList();
  }
}