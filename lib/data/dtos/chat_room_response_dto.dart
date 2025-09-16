import 'package:flutter/foundation.dart';

class ChatRoomResponseDto {
  final int chatRoomId;

  ChatRoomResponseDto({required this.chatRoomId});

  factory ChatRoomResponseDto.fromJson(Map<String, dynamic> json) {
    final dto = ChatRoomResponseDto(
      chatRoomId: json['chatRoomId'] as int? ?? 0,
    );

    if (kDebugMode) {
      print('[PARSED] ChatRoomResponseDto: ${dto.toString()}');
    }

    return dto;
  }

  @override
  String toString() {
    return 'ChatRoomResponseDto{chatRoomId: $chatRoomId}';
  }
}
