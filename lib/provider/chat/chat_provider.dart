
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/repositories/chat_repository.dart';
import '../../data/dtos/chat_message_dto.dart';
import '../core/dio_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatRepository(dio);
});

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

class ChatMessagesNotifier extends AutoDisposeFamilyNotifier<ChatMessagesState, int> {
  late final ChatRepository _chatRepository;
  late final int _chatRoomId;
  StreamSubscription<ChatMessageDto>? _messagesSubscription;

  int? _currentUserId;
  String? _currentUserType;

  @override
  ChatMessagesState build(int chatRoomId) {
    _chatRoomId = chatRoomId;
    _chatRepository = ref.watch(chatRepositoryProvider);

    ref.onDispose(() {
      _messagesSubscription?.cancel();
      _chatRepository.disconnectStomp();
    });

    return ChatMessagesState();
  }

  Future<void> connectAndListen({
    required String jwtToken,
    required int userId,
    required String userType,
  }) async {
    if (state.isConnected || state.isConnecting) return;

    _currentUserId = userId;
    _currentUserType = userType;

    state = state.copyWith(isConnecting: true, isLoading: true, clearErrorMessage: true);
    try {
      await fetchInitialMessages();

      await _chatRepository.connectStomp(_chatRoomId, jwtToken);
      state = state.copyWith(isConnected: true, isConnecting: false);

      _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository.messages.listen(
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
      final initialMessages = await _chatRepository.getMessagesByRoomId(_chatRoomId);
      state = state.copyWith(messages: initialMessages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '대화 기록을 불러오지 못했습니다.');
    }
  }

  void sendMessage({required String messageContent}) {
    if (!state.isConnected) {
      state = state.copyWith(errorMessage: "채팅 서버에 연결되어 있지 않습니다.");
      return;
    }

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

    _chatRepository.sendStompChatMessage(messageDto);
  }
}

final chatMessagesProvider = NotifierProvider.family.autoDispose<ChatMessagesNotifier, ChatMessagesState, int>(ChatMessagesNotifier.new);
