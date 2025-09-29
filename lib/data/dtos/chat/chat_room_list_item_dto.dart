class ChatRoomListItemDto {
  final int chatRoomId;
  final String opponentNickname;
  final String? opponentProfileImageUrl;
  final String? lastMessage;
  final String? lastMessageCreatedAt;
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
