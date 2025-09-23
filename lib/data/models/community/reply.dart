class Reply {
  final String id;
  final String author;
  final String authorId;
  final String authorBadge;
  final String content;
  final String timeAgo;
  final bool isActive;

  const Reply({
    required this.id,
    required this.author,
    required this.authorId,
    this.authorBadge = '',
    required this.content,
    required this.timeAgo,
    this.isActive = true,
  });

  /*
   * 서버로부터 받은 JSON 데이터를 Reply 객체로 변환합니다.
   * 백엔드 엔티티의 필드명과 일치시켜 매핑합니다.
  */
  factory Reply.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final userTypeCode = user?['userType']?['typeCode'] as String?;
    final isAdmin = (userTypeCode == 'admin');

    return Reply(
      id: json['replyId'].toString(),
      author: user?['username'] as String? ?? '알 수 없음',
      authorId: user?['userId']?.toString() ?? '',
      authorBadge: isAdmin ? '✅' : '',
      content: json['content'] as String,
      timeAgo: json['createdAt'] as String,
      isActive: (json['status'] as String) == 'ACTIVE',
    );
  }

  /*
   * Reply 객체를 JSON 데이터로 변환하여 서버에 보낼 수 있도록 합니다.
  */
  Map<String, dynamic> toJson() {
    return {
      'replyId': id,
      'content': content,
    };
  }

  /*
   * 기존 객체의 일부만 변경하여 새로운 Reply 객체를 생성합니다.
   * 상태 관리에서 댓글 데이터를 업데이트할 때 사용됩니다.
   */
  Reply copyWith({
    String? id,
    String? author,
    String? authorId,
    String? authorBadge,
    String? content,
    String? timeAgo,
    bool? isActive,
  }) {
    return Reply(
      id: id ?? this.id,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      authorBadge: authorBadge ?? this.authorBadge,
      content: content ?? this.content,
      timeAgo: timeAgo ?? this.timeAgo,
      isActive: isActive ?? this.isActive,
    );
  }
}
