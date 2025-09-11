import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_navigation_bar.dart'; // 공통 바텀바

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        "avatar": "assets/images/onbording.jpg",
        "sender": "조정우",
        "time": "1일전",
        "message": "결제가 완료 되었습니다! 결제...",
        "unread": true,
      },
      {
        "avatar": "assets/images/mini.png",
        "sender": "미니언즈",
        "time": "2일전",
        "message": "님이 메시지를 보냈습니다.",
        "unread": false,
      },
      {
        "avatar": "assets/images/onboarding2.jpg",
        "sender": "닮음",
        "time": "3일전",
        "message": "님이 메시지를 보냈습니다.",
        "unread": false,
      },
      {
        "avatar": "assets/images/dora.png",
        "sender": "하",
        "time": "4일전",
        "message": "님이 메시지를 보냈습니다.",
        "unread": false,
      },
      {
        "avatar": "assets/images/jjanggu.png",
        "sender": "배터지겠다",
        "time": "5일전",
        "message": "님이 메시지를 보냈습니다.",
        "unread": false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("알림"),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return NotificationItem(
            avatar: item["avatar"],
            sender: item["sender"],
            time: item["time"],
            message: item["message"],
            unread: item["unread"],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String avatar;
  final String sender;
  final String time;
  final String message;
  final bool unread;

  const NotificationItem({
    super.key,
    required this.avatar,
    required this.sender,
    required this.time,
    required this.message,
    this.unread = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage(avatar),
          ),
          if (unread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        "$sender  $time",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.black54, fontSize: 13),
      ),
    );
  }
}
