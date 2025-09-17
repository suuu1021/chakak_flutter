
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dtos/chat_room_create_request_dto.dart';
import '../../data/dtos/chat_room_response_dto.dart';
import '../auth/session_provider.dart';
import 'chat_provider.dart';

final createChatRoomProvider = FutureProvider.family<ChatRoomResponseDto, int>(
    (ref, photographerId) async {
  final chatService = ref.read(chatServiceProvider);
  final session = ref.read(sessionProvider);

  final userId = session.userId;
  if (userId == null) {
    throw Exception('로그인 정보를 찾을 수 없습니다.');
  }

  final requestDto = ChatRoomCreateRequestDto(
    userProfileId: userId,
    photographerProfileId: photographerId,
  );

  final chatRoomResponse = await chatService.createOrGetChatRoom(requestDto);

  return chatRoomResponse;
});
