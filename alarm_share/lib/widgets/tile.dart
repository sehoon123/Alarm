import 'package:flutter/material.dart';

class ExampleAlarmTile extends StatelessWidget {
  const ExampleAlarmTile({
    required this.title,
    required this.selectedDays,
    required this.onPressed,
    super.key,
    this.onDismissed,
  });

  final String title;
  final List<bool> selectedDays;
  final void Function() onPressed;
  final void Function()? onDismissed;

  @override
  Widget build(BuildContext context) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    List<String> activeDays = [];

    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        activeDays.add(days[i]);
      }
    }

    return RawMaterialButton(
      onPressed: onPressed,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right_rounded, size: 35),
              ],
            ),
            Text(
              activeDays.isNotEmpty ? activeDays.join(', ') : '반복 없음',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
