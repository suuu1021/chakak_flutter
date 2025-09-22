import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../_core/constants/sender_type.dart';
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
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ChatMessagesNotifier
    extends AutoDisposeFamilyNotifier<ChatMessagesState, int> {
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

  // 현재 채팅방 메시지 읽음 처리
  Future<void> markCurrentRoomMessagesAsRead() async {
    try {
      print('[ChatMessagesNotifier] 채팅방 ${_chatRoomId} 메시지 읽음 처리 시도');
      await _chatRepository.markMessagesAsRead(_chatRoomId);
      print('[ChatMessagesNotifier] 채팅방 ${_chatRoomId} 메시지 읽음 처리 성공');
    } catch (e) {
      print('[ChatMessagesNotifier] 채팅방 ${_chatRoomId} 메시지 읽음 처리 실패: $e');
      // 필요하다면 state.copyWith(errorMessage: ...)로 에러 상태 관리
    }
  }

  Future<void> connectAndListen({
    required String jwtToken,
    required int userId,
    required String userType,
  }) async {
    if (state.isConnected || state.isConnecting) return;

    _currentUserId = userId;
    _currentUserType = userType;

    state = state.copyWith(
        isConnecting: true, isLoading: true, clearErrorMessage: true);
    try {
      await fetchInitialMessages();
      await _chatRepository.connectStomp(_chatRoomId, jwtToken);
      state = state.copyWith(isConnected: true, isConnecting: false);

      // STOMP 연결 성공 후 메시지 읽음 처리 호출
      await markCurrentRoomMessagesAsRead();

      _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository.messages.listen((message) {
        if (!state.messages.any((m) =>
            m.chatMessageId != null &&
            m.chatMessageId == message.chatMessageId)) {
          state = state.copyWith(messages: [...state.messages, message]);
        }
      }, onError: (error) {
        state = state.copyWith(
            errorMessage: '메시지 수신 오류', isConnected: false, isConnecting: false);
      }, onDone: () {
        state = state.copyWith(isConnected: false, isConnecting: false);
      });
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          isConnected: false,
          isConnecting: false,
          errorMessage: '채팅 서버 연결 실패: ${e.toString()}');
    }
  }

  Future<void> fetchInitialMessages() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final initialMessages =
          await _chatRepository.getMessagesByRoomId(_chatRoomId);
      state = state.copyWith(messages: initialMessages, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, errorMessage: '대화 기록을 불러오지 못했습니다.');
    }
  }

  void sendMessage({required String messageContent}) {
    if (!state.isConnected) {
      state = state.copyWith(errorMessage: "채팅 서버에 연결되어 있지 않습니다.");
      return;
    }

    final senderId = _currentUserId;
    final senderTypeString = _currentUserType;

    if (senderId == null || senderTypeString == null) {
      state = state.copyWith(errorMessage: "사용자 정보를 찾을 수 없습니다.");
      return;
    }

    final messageDto = ChatMessageDto(
      chatRoomId: _chatRoomId,
      senderId: senderId,
      senderType: SenderType.fromJson(senderTypeString),
      messageType: 'TEXT',
      message: messageContent,
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    _chatRepository.sendStompChatMessage(messageDto);
  }

  // 이미지 메시지 전송
  void sendImageMessage({
    required String base64Image,
    required String fileName,
    required int fileSize,
  }) {
    if (!state.isConnected) {
      state = state.copyWith(errorMessage: "채팅 서버에 연결되어 있지 않습니다.");
      return;
    }

    final senderId = _currentUserId;
    final senderTypeString = _currentUserType;

    if (senderId == null || senderTypeString == null) {
      state = state.copyWith(errorMessage: "사용자 정보를 찾을 수 없습니다.");
      return;
    }

    final messageDto = ChatMessageDto(
      chatRoomId: _chatRoomId,
      senderId: senderId,
      senderType: SenderType.fromJson(senderTypeString),
      messageType: 'IMAGE',
      message: fileName, // 파일명을 메시지로 사용
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
      // 이미지 관련 필드들
      imageData: base64Image,
      fileName: fileName,
      fileSize: fileSize,
    );

    try {
      _chatRepository.sendStompChatMessage(messageDto);
      print(
          '[ChatMessagesNotifier] 이미지 메시지 전송 완료: $fileName (${fileSize}bytes)');
    } catch (e) {
      state = state.copyWith(errorMessage: "이미지 전송에 실패했습니다: ${e.toString()}");
      print('[ChatMessagesNotifier] 이미지 메시지 전송 실패: $e');
    }
  }

  // 결제 요청 메시지 전송
  void sendPaymentRequest({
    required String title,
    required int amount,
    String? description,
  }) {
    if (!state.isConnected) {
      state = state.copyWith(errorMessage: "채팅 서버에 연결되어 있지 않습니다.");
      return;
    }

    final senderId = _currentUserId;
    final senderTypeString = _currentUserType;

    if (senderId == null || senderTypeString == null) {
      state = state.copyWith(errorMessage: "사용자 정보를 찾을 수 없습니다.");
      return;
    }

    final messageDto = ChatMessageDto(
      chatRoomId: _chatRoomId,
      senderId: senderId,
      senderType: SenderType.fromJson(senderTypeString),
      messageType: 'PAYMENT_REQUEST',
      message: title, // 결제 요청 제목
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
      // 결제 관련 필드들
      paymentAmount: amount,
      paymentDescription: description,
    );

    try {
      _chatRepository.sendStompChatMessage(messageDto);
      print('[ChatMessagesNotifier] 결제 요청 메시지 전송 완료: $title (${amount}원)');
    } catch (e) {
      state = state.copyWith(errorMessage: "결제 요청 전송에 실패했습니다: ${e.toString()}");
      print('[ChatMessagesNotifier] 결제 요청 메시지 전송 실패: $e');
    }
  }
}

final chatMessagesProvider = NotifierProvider.family
    .autoDispose<ChatMessagesNotifier, ChatMessagesState, int>(
        ChatMessagesNotifier.new);
