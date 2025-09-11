import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("알림"),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: const [
          NotificationItem(
            avatar: "assets/images/onbording.jpg",
            sender: "퉁퉁이",
            time: "1일전",
            message: "결제가 완료 되었습니다! 결제...",
            unread: true,
          ),
          NotificationItem(
            avatar: "assets/images/onboarding2.jpg",
            sender: "짱구",
            time: "1일전",
            message: "님이 메시지를 보냈습니다.",
            unread: false,
          ),
          NotificationItem(
            avatar: "assets/images/onbording.jpg",
            sender: "도라에몽",
            time: "1일전",
            message: "예약이 완료 되었습니다! 예약...",
            unread: true,
          ),
          NotificationItem(
            avatar: "assets/images/onboarding2.jpg",
            sender: "조정우",
            time: "3일 전",
            message: "님이 메시지를 보냈습니다.",
            unread: false,
          ),
          NotificationItem(
            avatar: "assets/images/onbording.jpg",
            sender: "미니언즈",
            time: "5일 전",
            message: "님이 메시지를 보냈습니다.",
            unread: false,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "검색"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "예약"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "마이"),
        ],
      ),
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
