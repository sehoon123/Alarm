import 'package:flutter/material.dart';

class NotificationCarousel extends StatefulWidget {
  const NotificationCarousel({super.key});

  @override
  _NotificationCarouselState createState() => _NotificationCarouselState();
}

class _NotificationCarouselState extends State<NotificationCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildNotificationCard('202X년 XX월 X주차 응모 마감까지\nOO시간 OO분 OO초'),
                _buildNotificationCard('또 다른 알림 텍스트 예시 1'),
                _buildNotificationCard('또 다른 알림 텍스트 예시 2'),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8.0,
                width: _currentPage == index ? 16.0 : 8.0,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.purple : Colors.grey,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String text) {
    return Padding(
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
    );
  }
}
