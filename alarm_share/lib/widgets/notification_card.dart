import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String text;
  final Function() clicked;

  const NotificationCard(
      {super.key, required this.text, required this.clicked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: clicked,
      child: Padding(
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
      ),
    );
  }
}
