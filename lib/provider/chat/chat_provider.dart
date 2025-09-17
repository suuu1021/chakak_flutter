
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/chat_service.dart';
import '../../data/dtos/chat_message_dto.dart';
import '../core/dio_provider.dart';
// session_provider import는 이 파일에서 더 이상 필요 없습니다.

// 1. ChatService 프로바이더
final chatServiceProvider = Provider<ChatService>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatService(dio);
});

// 2. 채팅 메시지 및 상태 관리를 위한 상태 클래스
class ChatMessagesState {
  final List<ChatMessageDto> messages;
  final bool isLoading;
  final bool isConnecting;
  final bool isConnected;
  final String? errorMessage;

  ChatMessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnecting = false,
    this.isConnected = false,
    this.errorMessage,
  });

  ChatMessagesState copyWith({
    List<ChatMessageDto>? messages,
    bool? isLoading,
    bool? isConnecting,
    bool? isConnected,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// 3. 채팅 메시지 및 상태 관리를 위한 StateNotifier (사용자 의도대로 복구)
class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ChatService _chatService;
  final int _chatRoomId;
  StreamSubscription<ChatMessageDto>? _messagesSubscription;

  // 내부 상태로 사용자 정보 저장 (원상 복구)
  int? _currentUserId;
  String? _currentUserType;

  // 생성자 단순화 (원상 복구)
  ChatMessagesNotifier(this._chatService, this._chatRoomId) : super(ChatMessagesState());

  // connectAndListen 메서드 시그니처 원상 복구
  Future<void> connectAndListen({
    required String jwtToken,
    required int userId,
    required String userType,
  }) async {
    if (state.isConnected || state.isConnecting) return;

    // 전달받은 사용자 정보를 내부에 저장 (원상 복구)
    _currentUserId = userId;
    _currentUserType = userType;

    state = state.copyWith(isConnecting: true, isLoading: true, clearErrorMessage: true);
    try {
      await fetchInitialMessages();

      await _chatService.connectStomp(_chatRoomId, jwtToken);
      state = state.copyWith(isConnected: true, isConnecting: false);

      _messagesSubscription?.cancel();
      _messagesSubscription = _chatService.messages.listen(
        (message) {
          if (!state.messages.any((m) => m.chatMessageId != null && m.chatMessageId == message.chatMessageId)) {
             state = state.copyWith(messages: [...state.messages, message]);
          }
        },
        onError: (error) {
          state = state.copyWith(errorMessage: '메시지 수신 오류', isConnected: false, isConnecting: false);
        },
        onDone: () {
          state = state.copyWith(isConnected: false, isConnecting: false);
        }
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isConnected: false, isConnecting: false, errorMessage: '채팅 서버 연결 실패');
    }
  }

  Future<void> fetchInitialMessages() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final initialMessages = await _chatService.getMessagesByRoomId(_chatRoomId);
      state = state.copyWith(messages: initialMessages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '대화 기록을 불러오지 못했습니다.');
    }
  }

  // sendMessage 메서드 원상 복구
  void sendMessage({required String messageContent}) {
    if (!state.isConnected) {
      state = state.copyWith(errorMessage: "채팅 서버에 연결되어 있지 않습니다.");
      return;
    }

    // 내부 저장된 사용자 정보 사용 (원상 복구)
    final senderId = _currentUserId;
    final senderType = _currentUserType;

    if (senderId == null || senderType == null) {
      state = state.copyWith(errorMessage: "사용자 정보를 찾을 수 없습니다.");
      return;
    }

    final messageDto = ChatMessageDto(
      chatRoomId: _chatRoomId,
      senderId: senderId,
      senderType: senderType,
      messageType: 'TEXT',
      message: messageContent,
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    _chatService.sendStompChatMessage(messageDto);
  }

  void disconnect() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _chatService.disconnectStomp();
    state = state.copyWith(isConnected: false, isConnecting: false);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

// 4. StateNotifierProvider.family 원상 복구
final chatMessagesProvider = StateNotifierProvider.family.autoDispose<ChatMessagesNotifier, ChatMessagesState, int>((ref, chatRoomId) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatMessagesNotifier(chatService, chatRoomId);
});
