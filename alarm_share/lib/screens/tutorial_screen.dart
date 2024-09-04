import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용 설명')),
      body: PageView(
        children: const [
          TutorialPage('알람 설정 방법', '메인 화면에서 + 버튼을 눌러 새 알람을 추가하세요.'),
          TutorialPage('알람 수정', '알람을 길게 누르면 수정할 수 있습니다.'),
          TutorialPage('알람 삭제', '알람을 왼쪽으로 스와이프하여 삭제할 수 있습니다.'),
        ],
      ),
    );
  }
}

class TutorialPage extends StatelessWidget {
  final String title;
  final String description;

  const TutorialPage(this.title, this.description, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
