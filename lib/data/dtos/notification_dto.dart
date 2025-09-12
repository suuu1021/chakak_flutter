class NotificationDto {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String avatar; // 이미지 경로 추가

  NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.avatar,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      avatar: json['avatar'] ?? "assets/images/default.png",
    );
  }
}
