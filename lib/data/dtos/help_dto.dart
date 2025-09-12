class HelpDto {
  final String id;
  final String userId;
  final String category;     // 예: "FAQ", "문의"
  final String content;      // 문의 내용
  final DateTime createdAt;
  final String? status;      // 예: "PENDING", "ANSWERED"

  HelpDto({
    required this.id,
    required this.userId,
    required this.category,
    required this.content,
    required this.createdAt,
    this.status,
  });

  factory HelpDto.fromJson(Map<String, dynamic> json) {
    return HelpDto(
      id: json['id'],
      userId: json['user_id'],
      category: json['category'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
    );
  }
}
