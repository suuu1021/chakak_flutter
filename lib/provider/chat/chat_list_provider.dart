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

      // 실제 API 호출
      final chatRooms = await _chatService.getMyChatRooms();

      state = state.copyWith(
        chatRooms: chatRooms,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '채팅방 목록을 불러오는데 실패했습니다: ${e.toString()}',
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
