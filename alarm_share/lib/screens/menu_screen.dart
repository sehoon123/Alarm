import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('설정'),
          onTap: () {
            // 설정 페이지로 이동
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('도움말'),
          onTap: () {
            // 도움말 페이지로 이동
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('앱 정보'),
          onTap: () {
            // 앱 정보 페이지로 이동
          },
        ),
      ],
    );
  }
}
