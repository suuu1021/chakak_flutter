import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dtos/chat/chat_room_list_item_dto.dart';
import 'chat_provider.dart';

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

class ChatListNotifier extends Notifier<ChatListState> {
  @override
  ChatListState build() {
    return const ChatListState();
  }

  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final chatRepository = ref.read(chatRepositoryProvider);
      final chatRooms = await chatRepository.getMyChatRooms();
      state = state.copyWith(chatRooms: chatRooms, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: '채팅방 목록을 불러오는데 실패했습니다: ${e.toString()}');
    }
  }

  Future<void> refresh() async {
    await loadChatRooms();
  }
}

final chatListProvider =
    NotifierProvider<ChatListNotifier, ChatListState>(ChatListNotifier.new);
