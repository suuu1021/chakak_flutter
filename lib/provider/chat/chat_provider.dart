import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_core/constants/sender_type.dart';
import '../../data/dtos/booking/booking_request_dto.dart';
import '../../data/dtos/chat/chat_message_dto.dart';
import '../../data/models/_repositories/booking_repository.dart';
import '../../data/models/_repositories/chat_repository.dart';
import '../../data/models/_repositories/photo_service_repository.dart';
import '../core/dio_provider.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final repository = BookingRepository();
  repository.init();
  return repository;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatRepository(dio);
});

final photoServiceRepositoryProvider = Provider<PhotoServiceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PhotoServiceRepositoryImpl(dio);
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

  late final BookingRepository _bookingRepository;
  int? _currentUserId;
  String? _currentUserType;
  int? _opponentUserId;

  int? get opponentUserId => _opponentUserId;

  @override
  ChatMessagesState build(int chatRoomId) {
    _chatRoomId = chatRoomId;
    _chatRepository = ref.watch(chatRepositoryProvider);
    _bookingRepository = ref.watch(bookingRepositoryProvider);

    ref.onDispose(() {
      _messagesSubscription?.cancel();
      _chatRepository.disconnectStomp();
    });

    return ChatMessagesState();
  }

  Future<void> markCurrentRoomMessagesAsRead() async {
    try {
      print('[ChatMessagesNotifier] 채팅방 ${_chatRoomId} 메시지 읽음 처리 시도');
      await _chatRepository.markMessagesAsRead(_chatRoomId);
      print('[ChatMessagesNotifier] 채팅방 ${_chatRoomId} 메시지 읽음 처리 성공');
    } catch (e) {
      print('[ChatMessagesNotifier] 채팅방 ${_chatRoomId} 메시지 읽음 처리 실패: $e');
    }
  }

  Future<void> connectAndListen({
    required String jwtToken,
    required int userId,
    required String userType,
    int? opponentUserId,
  }) async {
    if (state.isConnected || state.isConnecting) return;

    _currentUserId = userId;
    _currentUserType = userType;
    _opponentUserId = opponentUserId;

    _bookingRepository.setAuthToken(jwtToken);

    state = state.copyWith(
        isConnecting: true, isLoading: true, clearErrorMessage: true);
    try {
      await fetchInitialMessages();
      await _chatRepository.connectStomp(_chatRoomId, jwtToken);
      state = state.copyWith(isConnected: true, isConnecting: false);

      await markCurrentRoomMessagesAsRead();

      _messagesSubscription?.cancel();
      _messagesSubscription = _chatRepository.messages.listen((message) {
        if (kDebugMode) {
          print('[DEBUG][ChatProvider] 서버로부터 메시지 수신: ${message.toJson()}');
        }

        if (!state.messages.any((m) =>
            m.chatMessageId != null &&
            m.chatMessageId == message.chatMessageId)) {
          state = state.copyWith(messages: [...state.messages, message]);
        }
      }, onError: (error) {
        if (kDebugMode) {
          print('[DEBUG][ChatProvider] 메시지 스트림 에러: $error');
        }
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

      if (_opponentUserId == null &&
          _currentUserId != null &&
          initialMessages.isNotEmpty) {
        for (final message in initialMessages) {
          if (message.senderId != _currentUserId) {
            _opponentUserId = message.senderId;
            print('[ChatMessagesNotifier] 메시지에서 상대방 ID 추출: $_opponentUserId');
            break;
          }
        }
      }

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

  void sendImageMessage({
    required String base64Image,
    required String fileName,
    required int fileSize,
    String? message,
  }) {
    if (!state.isConnected ||
        _currentUserId == null ||
        _currentUserType == null) {
      print('[ChatProvider] 이미지 전송 불가: 연결되지 않았거나 사용자 정보 없음');
      return;
    }

    final messageDto = ChatMessageDto(
      chatRoomId: _chatRoomId,
      senderId: _currentUserId!,
      senderType: SenderType.fromJson(_currentUserType!),
      messageType: 'IMAGE',
      message: message ?? '',
      imageBase64: base64Image,
      imageOriginalName: fileName,
      createdAt: DateTime.now().toIso8601String(),
      fileSize: fileSize,
    );

    try {
      print('[ChatProvider] 이미지 메시지 전송 시도: ${messageDto.toJson()}');
      _chatRepository.sendStompChatMessage(messageDto);
    } catch (e) {
      print('[ChatProvider] 이미지 메시지 전송 실패: $e');
      state = state.copyWith(errorMessage: "이미지 전송에 실패했습니다: ${e.toString()}");
    }
  }

  Future<void> sendPaymentRequest({
    required String title,
    required int amount,
    String? description,
    required int photoServiceInfoId,
    required int priceInfoId,
    required int photographerId,
    required int userProfileId,
  }) async {
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

    if (_opponentUserId == null) {
      state = state.copyWith(errorMessage: "상대방 정보가 없어 결제 요청을 보낼 수 없습니다.");
      print('[ChatMessagesNotifier] 상대방 ID가 없어 결제 요청을 중단합니다.');
      return;
    }

    try {
      final now = DateTime.now();
      final bookingDto = BookingCreateRequestDto(
        photographerProfileId: photographerId,
        userProfileId: userProfileId,
        photoServiceInfoId: photoServiceInfoId,
        priceInfoId: priceInfoId,
        bookingDate: now.toIso8601String().substring(0, 10),
        bookingTime:
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00',
        specialRequests: description,
      );

      print('[ChatMessagesNotifier] 예약 생성 요청 데이터:');
      print('  - photographerProfileId: $photographerId (photographer.id)');
      print('  - userProfileId: $userProfileId (상대방 ID)');
      print('  - photoServiceInfoId: $photoServiceInfoId');
      print('  - priceInfoId: $priceInfoId');
      print('[ChatMessagesNotifier] 생성된 DTO:');
      print('  - bookingDate: ${bookingDto.bookingDate}');
      print('  - bookingTime: ${bookingDto.bookingTime}');
      print('  - specialRequests: ${bookingDto.specialRequests}');

      print('[ChatMessagesNotifier] 전송할 JSON:');
      print(json.encode(bookingDto.toJson()));

      final response = await _bookingRepository.createBooking(bookingDto);
      print('[ChatMessagesNotifier] 예약 생성 API 호출 완료');

      final bookingInfoId = json.decode(response.body)['body']['bookingInfoId'];
      print('[ChatMessagesNotifier] 추출된 bookingInfoId: $bookingInfoId');

      final messageDto = ChatMessageDto(
        chatRoomId: _chatRoomId,
        senderId: senderId,
        senderType: SenderType.fromJson(senderTypeString),
        messageType: 'PAYMENT_REQUEST',
        message: title,
        isRead: false,
        createdAt: DateTime.now().toIso8601String(),
        paymentAmount: amount,
        paymentDescription: description,
        photoServiceInfoId: photoServiceInfoId,
        priceInfoId: priceInfoId,
        bookingInfoId: bookingInfoId,
      );

      _chatRepository.sendStompChatMessage(messageDto);
      print('[ChatMessagesNotifier] 결제 요청 메시지 전송 완료: $title (${amount}원)');
    } catch (e) {
      state = state.copyWith(errorMessage: "결제 요청 처리에 실패했습니다: ${e.toString()}");
      print('[ChatMessagesNotifier] 결제 요청 처리 실패: $e');
    }
  }
}

final chatMessagesProvider = NotifierProvider.family
    .autoDispose<ChatMessagesNotifier, ChatMessagesState, int>(
        ChatMessagesNotifier.new);
