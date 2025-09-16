import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dtos/chat_room_create_request_dto.dart';
import '../../data/dtos/chat_room_response_dto.dart';
import '../auth/session_provider.dart';
import 'chat_provider.dart';

/// 채팅방 생성 또는 조회를 위한 FutureProvider
final createChatRoomProvider = FutureProvider.family<ChatRoomResponseDto, int>(
    (ref, photographerId) async {
  final session = ref.read(sessionProvider);
  final chatService = ref.read(chatServiceProvider);

  // 서버에 보낼 요청 DTO 생성
  final requestDto = ChatRoomCreateRequestDto(
    userProfileId: session.userId, // 현재 로그인한 사용자 ID
    photographerProfileId: photographerId, // 채팅할 상대방 사진작가 ID
  );

  // ChatService를 통해 채팅방 생성 또는 조회 요청
  final chatRoomResponse = await chatService.createOrGetChatRoom(requestDto);

  return chatRoomResponse;
});
