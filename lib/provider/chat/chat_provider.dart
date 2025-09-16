
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/chat_service.dart';
import '../../data/dtos/chat_message_dto.dart';
import '../core/dio_provider.dart';

// 1. ChatService 프로바이더 (수정)
// autoDispose를 제거하여 ChatService 인스턴스가 앱 전역에서 단 하나만 생성되고 유지되도록 합니다.
final chatServiceProvider = Provider<ChatService>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatService(dio);
});

// 2. 채팅 메시지 및 상태 관리를 위한 상태 클래스 (변경 없음)
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

// 3. 채팅 메시지 및 상태 관리를 위한 StateNotifier (대대적 수정)
class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ChatService _chatService;
  final int _chatRoomId;
  StreamSubscription<ChatMessageDto>? _messagesSubscription;

  // 내부 상태로 사용자 정보 저장
  int? _currentUserId;
  String? _currentUserType;

  // 생성자 단순화: Ref 제거, 자동 호출 제거
  ChatMessagesNotifier(this._chatService, this._chatRoomId) : super(ChatMessagesState());

  // connectAndListen 메서드 시그니처 변경
  Future<void> connectAndListen({
    required String jwtToken,
    required int userId,
    required String userType,
  }) async {
    if (state.isConnected || state.isConnecting) return;

    // 전달받은 사용자 정보를 내부에 저장
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

  // sendMessage 메서드 시그니처 변경
  void sendMessage({required String messageContent}) {
    if (!state.isConnected) {
      state = state.copyWith(errorMessage: "채팅 서버에 연결되어 있지 않습니다.");
      return;
    }

    // 내부 저장된 사용자 정보 사용
    final senderId = _currentUserId;
    var senderType = _currentUserType;

    // userType이 null이거나 비어있을 경우, 서버가 이해할 수 있는 기본값 'USER'를 할당합니다.
    if (senderType == null || senderType.isEmpty) {
      senderType = 'USER';
    }

    if (senderId == null) {
      // 이제 senderId만 확인하면 됩니다.
      state = state.copyWith(errorMessage: "사용자 정보를 찾을 수 없습니다 (ID 없음).");
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

    // [수정] 낙관적 UI 업데이트 코드를 제거합니다.
    // 이제 메시지는 서버로부터 수신될 때만 상태에 추가됩니다.
    // state = state.copyWith(messages: [...state.messages, messageDto]);

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

// 4. StateNotifierProvider.family 수정: Notifier 생성자 변경에 따라 Ref 제거
final chatMessagesProvider = StateNotifierProvider.family.autoDispose<ChatMessagesNotifier, ChatMessagesState, int>((ref, chatRoomId) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatMessagesNotifier(chatService, chatRoomId);
});
