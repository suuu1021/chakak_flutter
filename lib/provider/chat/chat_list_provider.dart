import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dtos/chat_room_list_item_dto.dart';
import '../../../service/chat_service.dart';
import '../core/dio_provider.dart';

// State 클래스
class ChatListState {
  final List<ChatRoomListItemDto> chatRooms;
  final bool isLoading;
  final String? errorMessage;

  const ChatListState({
    this.chatRooms = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ChatListState copyWith({
    List<ChatRoomListItemDto>? chatRooms,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatListState(
      chatRooms: chatRooms ?? this.chatRooms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier 클래스
class ChatListNotifier extends StateNotifier<ChatListState> {
  final ChatService _chatService;

  ChatListNotifier(this._chatService) : super(const ChatListState());

  Future<void> loadChatRooms() async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);

      // 실제 API 호출 (현재는 모의 데이터로 대체)
      // final chatRooms = await _chatService.getChatRoomList();

      // 임시 모의 데이터
      await Future.delayed(const Duration(milliseconds: 500));
      final mockData = [
        ChatRoomListItemDto(
          chatRoomId: 1,
          opponentNickname: "김포토그래퍼",
          opponentProfileImageUrl: null,
          lastMessage: "웨딩 촬영 견적서입니다. 확인 후 결제 부탁드립니다.",
          lastMessageCreatedAt: DateTime.now()
              .subtract(const Duration(minutes: 30))
              .toIso8601String(),
          unreadMessageCount: 1,
        ),
        ChatRoomListItemDto(
          chatRoomId: 2,
          opponentNickname: "박작가님",
          opponentProfileImageUrl: null,
          lastMessage: "네, 좋습니다! 그때 뵙겠습니다.",
          lastMessageCreatedAt: DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          unreadMessageCount: 0,
        ),
        ChatRoomListItemDto(
          chatRoomId: 3,
          opponentNickname: "이스튜디오",
          opponentProfileImageUrl: null,
          lastMessage: "프로필 촬영 예약 가능한 시간대 알려드릴게요.",
          lastMessageCreatedAt: DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          unreadMessageCount: 0,
        ),
      ];

      state = state.copyWith(
        chatRooms: mockData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '채팅방 목록을 불러오는데 실패했습니다.',
      );
    }
  }

  Future<void> refresh() async {
    await loadChatRooms();
  }
}

// Provider
final chatListProvider =
    StateNotifierProvider<ChatListNotifier, ChatListState>((ref) {
  final dio = ref.watch(dioProvider);
  final chatService = ChatService(dio);
  return ChatListNotifier(chatService);
});
