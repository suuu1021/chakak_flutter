
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../dtos/chat_message_dto.dart';
import '../../dtos/chat_room_create_request_dto.dart';
import '../../dtos/chat_room_list_item_dto.dart';
import '../../dtos/chat_room_response_dto.dart';

class ChatRepository {
  final Dio _dio;
  final String stompConnectUrl = 'ws://localhost:8080/ws';

  StompClient? _stompClient;
  StompUnsubscribe? _currentSubscription;
  final _messageStreamController = StreamController<ChatMessageDto>.broadcast();

  Stream<ChatMessageDto> get messages => _messageStreamController.stream;

  ChatRepository(this._dio) {
    print("[ChatRepository] 생성됨");
  }

  Future<ChatRoomResponseDto> createOrGetChatRoom(
      ChatRoomCreateRequestDto requestDto) async {
    final response = await _dio.post('/api/chat/rooms', data: requestDto.toJson());
    return ChatRoomResponseDto.fromJson(response.data);
  }

  Future<List<ChatMessageDto>> getMessagesByRoomId(int chatRoomId) async {
    final response = await _dio.get('/api/chat/rooms/$chatRoomId/messages');
    final List<dynamic> responseData = response.data as List<dynamic>;
    return responseData.map((e) => ChatMessageDto.fromJson(e)).toList();
  }

  Future<void> markMessagesAsRead(int chatRoomId) async {
    await _dio.post('/api/chat/rooms/$chatRoomId/read');
  }

  Future<List<ChatRoomListItemDto>> getMyChatRooms() async {
    final response = await _dio.get('/api/chat/my/rooms');
    final List<dynamic> responseData = response.data as List<dynamic>;
    return responseData.map((e) => ChatRoomListItemDto.fromJson(e)).toList();
  }

  Future<void> connectStomp(int chatRoomId, String jwtToken) async {
    print('[ChatRepository] STOMP 연결 시도... Room: $chatRoomId');
    if (_stompClient != null && _stompClient!.connected) {
      print('[ChatRepository] 이미 연결된 상태. 재연결 안함. Room: $chatRoomId');
      return;
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: stompConnectUrl,
        stompConnectHeaders: {
          'Authorization': 'Bearer $jwtToken',
        },
        onConnect: (StompFrame frame) {
          print('[ChatRepository] STOMP 연결 성공! Room: $chatRoomId');
          _currentSubscription?.call();
          final destination = '/topic/chat/room/$chatRoomId';
          _currentSubscription = _stompClient!.subscribe(
            destination: destination,
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  final data = jsonDecode(frame.body!);
                  _messageStreamController.add(
                    ChatMessageDto.fromJson(data as Map<String, dynamic>),
                  );
                } catch (e) {
                  print('[ChatRepository] !!!!! 메시지 파싱 오류 !!!!!: $e');
                }
              }
            },
          );
        },
        onWebSocketError: (err) => print('[ChatRepository] !!!!! 웹소켓 오류 !!!!!: $err'),
        onStompError: (frame) => print('[ChatRepository] !!!!! STOMP 프로토콜 오류 !!!!!: ${frame.body}'),
        onDisconnect: (_) {
          print('[ChatRepository] STOMP 연결 끊김. Room: $chatRoomId');
          _currentSubscription?.call();
          _currentSubscription = null;
        },
      ),
    );

    _stompClient!.activate();
    print('[ChatRepository] StompClient 활성화.');
  }

  void sendStompChatMessage(ChatMessageDto message) {
    if (_stompClient == null || !_stompClient!.connected) {
      print('[ChatRepository] STOMP 연결 안됨. 메시지 전송 실패.');
      return;
    }
    final destination = '/app/chat/room/${message.chatRoomId}';
    _stompClient!.send(
      destination: destination,
      body: jsonEncode(message.toJson()),
    );
  }

  void disconnectStomp() {
    print('[ChatRepository] STOMP 연결 해제 요청.');
    _currentSubscription?.call();
    _currentSubscription = null;
    _stompClient?.deactivate();
    _stompClient = null;
    print('[ChatRepository] STOMP 연결 해제 완료.');
  }

  void dispose() {
    print("[ChatRepository] dispose 호출됨. 스트림 닫고 연결 해제.");
    disconnectStomp();
    _messageStreamController.close();
  }
}
