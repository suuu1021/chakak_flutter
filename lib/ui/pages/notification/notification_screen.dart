import 'package:chakak_flutter/data/dtos/notification_dto.dart';
import 'package:flutter/material.dart';

import 'widgets/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📌 Mock DTO 리스트 (각 알림별 다른 이미지 적용)
    final notifications = [
      NotificationDto(
        id: "1",
        title: "조정우= 미니언즈",
        message: "결제가 완료 되었습니다! 결제...",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        avatar: "assets/images/onbording.jpg",
      ),
      NotificationDto(
        id: "2",
        title: "미니언즈",
        message: "님이 메시지를 보냈습니다.",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        avatar: "assets/images/mini.png",
      ),
      NotificationDto(
        id: "3",
        title: "짱구",
        message: "새 메시지가 도착했습니다.",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isRead: false,
        avatar: "assets/images/jjanggu.png",
      ),
      NotificationDto(
        id: "4",
        title: "도라에몽",
        message: "님이 메시지를 보냈습니다.",
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        isRead: true,
        avatar: "assets/images/dora.png",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("알림"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "알림이 없습니다.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView(
              children:
                  notifications.map((n) => NotificationItem(dto: n)).toList(),
            ),
    );
  }
}
