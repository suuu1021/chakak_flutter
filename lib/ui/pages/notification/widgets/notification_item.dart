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
          _buildAvatar(),
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

  Widget _buildAvatar() {
    if (dto.avatar.isEmpty) {
      return _buildPlaceholderAvatar();
    }

    // HTTP URL인 경우 네트워크 이미지
    if (dto.avatar.startsWith('http')) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(dto.avatar),
        onBackgroundImageError: (exception, stackTrace) {
          // 에러 발생시 기본 처리
        },
      );
    }

    // 로컬 asset 이미지인 경우
    return CircleAvatar(
      radius: 22,
      backgroundImage: AssetImage(dto.avatar),
      onBackgroundImageError: (exception, stackTrace) {
        // 에러 발생시 기본 처리
      },
    );
  }

  Widget _buildPlaceholderAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey[300],
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 24,
      ),
    );
  }
}
