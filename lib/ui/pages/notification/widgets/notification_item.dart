import 'package:flutter/material.dart';
import 'package:chakak_flutter/data/dtos/notification_dto.dart';

class NotificationItem extends StatelessWidget {
  final NotificationDto dto;

  const NotificationItem({super.key, required this.dto});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage(dto.avatar), // DTO의 avatar 사용
          ),
          if (!dto.isRead)
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
        "${dto.title}  ${DateTime.now().difference(dto.createdAt).inDays}일 전",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        dto.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.black54, fontSize: 13),
      ),
    );
  }
}
