class ChatRoomListItemDto {
  final int chatRoomId;
  final String opponentNickname;
  final String? opponentProfileImageUrl; // nullable로 처리
  final String? lastMessage; // nullable (메시지가 없을 수 있음)
  final String? lastMessageCreatedAt; // nullable, ISO 8601 형식
  final int unreadMessageCount;

  ChatRoomListItemDto({
    required this.chatRoomId,
    required this.opponentNickname,
    this.opponentProfileImageUrl,
    this.lastMessage,
    this.lastMessageCreatedAt,
    required this.unreadMessageCount,
  });

  factory ChatRoomListItemDto.fromJson(Map<String, dynamic> json) {
    return ChatRoomListItemDto(
      chatRoomId: json['chatRoomId'] as int,
      opponentNickname: json['opponentNickname'] as String,
      opponentProfileImageUrl: json['opponentProfileImageUrl'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageCreatedAt: json['lastMessageCreatedAt'] as String?,
      unreadMessageCount: json['unreadMessageCount'] as int,
    );
  }

  // toJson은 이 DTO가 서버로 전송될 일이 없으면 생략 가능
  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'opponentNickname': opponentNickname,
      if (opponentProfileImageUrl != null) 'opponentProfileImageUrl': opponentProfileImageUrl,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageCreatedAt != null) 'lastMessageCreatedAt': lastMessageCreatedAt,
      'unreadMessageCount': unreadMessageCount,
    };
  }
}
