class ChatRoomResponseDto {
  final int chatRoomId;

  ChatRoomResponseDto({required this.chatRoomId});

  factory ChatRoomResponseDto.fromJson(Map<String, dynamic> json) {
    return ChatRoomResponseDto(
      chatRoomId: json['chatRoomId'],
    );
  }
}
