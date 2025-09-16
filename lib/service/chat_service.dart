import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../_core/constants/api_config.dart';
import '../data/dtos/chat_room_create_request_dto.dart';
import '../data/dtos/chat_room_response_dto.dart';
import '../data/dtos/chat_message_dto.dart';
import '../data/dtos/chat_room_list_item_dto.dart';

class ChatService {
  final Dio _dio;
  final String _apiBaseUrl = ApiConfig.baseUrl;
  final String stompConnectUrl = 'ws://localhost:8080/ws';

  StompClient? _stompClient;
  StompUnsubscribe? _currentSubscription; //
  final _messageStreamController = StreamController<ChatMessageDto>.broadcast();

  Stream<ChatMessageDto> get messages => _messageStreamController.stream;

  ChatService(this._dio) {
    print("[ChatService] 생성됨");
  }

  // 채팅방 생성 및 조회
  Future<ChatRoomResponseDto> createOrGetChatRoom(
      ChatRoomCreateRequestDto requestDto) async {
    print("[ChatService] createOrGetChatRoom 호출됨. 요청: ${requestDto.toJson()}");
    try {
      final response = await _dio.post(
        '$_apiBaseUrl/api/chat/rooms',
        data: requestDto.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("[ChatService] 채팅방 생성/조회 성공. 응답: ${response.data}");
        return ChatRoomResponseDto.fromJson(response.data);
      } else {
        throw Exception('채팅방 생성 또는 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          "[ChatService] !!!!! createOrGetChatRoom DioException: ${e.message}");
      throw Exception('채팅방 생성/조회 실패: ${e.message}');
    }
  }

  // 채팅방 메시지 조회
  Future<List<ChatMessageDto>> getMessagesByRoomId(int chatRoomId) async {
    print("[ChatService] getMessagesByRoomId 호출됨. 채팅방 ID: $chatRoomId");
    try {
      final response =
          await _dio.get('$_apiBaseUrl/api/chat/rooms/$chatRoomId/messages');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data as List<dynamic>;
        print("[ChatService] 메시지 목록 조회 성공. ${responseData.length}개 메시지 수신.");
        return responseData.map((e) => ChatMessageDto.fromJson(e)).toList();
      } else {
        throw Exception('메시지 목록 불러오기 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          "[ChatService] !!!!! getMessagesByRoomId DioException: ${e.message}");
      throw Exception('메시지 목록 불러오기 실패: ${e.message}');
    }
  }

  // 메시지 읽음 처리
  Future<void> markMessagesAsRead(int chatRoomId) async {
    print("[ChatService] markMessagesAsRead 호출됨. 채팅방 ID: $chatRoomId");
    try {
      final response =
          await _dio.post('$_apiBaseUrl/api/chat/rooms/$chatRoomId/read');
      if (response.statusCode == 200) {
        print("[ChatService] 메시지 읽음 처리 요청 성공. 채팅방 ID: $chatRoomId");
      } else {
        throw Exception('메시지 읽음 처리 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          "[ChatService] !!!!! markMessagesAsRead DioException: ${e.message}");
      throw Exception('메시지 읽음 처리 실패: ${e.message}');
    }
  }

  // 내 채팅방 목록 조회
  Future<List<ChatRoomListItemDto>> getMyChatRooms() async {
    print("[ChatService] getMyChatRooms 호출됨.");
    try {
      final response = await _dio.get('$_apiBaseUrl/api/chat/my/rooms');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data as List<dynamic>;
        print("[ChatService] 내 채팅방 목록 조회 성공. ${responseData.length}개 채팅방 수신.");
        return responseData
            .map((e) => ChatRoomListItemDto.fromJson(e))
            .toList();
      } else {
        throw Exception('내 채팅방 목록 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("[ChatService] !!!!! getMyChatRooms DioException: ${e.message}");
      throw Exception('내 채팅방 목록 조회 실패: ${e.message}');
    }
  }

  // STOMP 연결
  Future<void> connectStomp(int chatRoomId, String jwtToken) async {
    print('[ChatService] STOMP 연결 시도... Room: $chatRoomId');
    if (_stompClient != null && _stompClient!.connected) {
      print('[ChatService] 이미 연결된 상태. 재연결 안함. Room: $chatRoomId');
      return;
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: stompConnectUrl,
        stompConnectHeaders: {
          'Authorization': 'Bearer $jwtToken',
        },
        onConnect: (StompFrame frame) {
          print('[ChatService] STOMP 연결 성공! Room: $chatRoomId');

          // 이전 구독 해제
          _currentSubscription?.call();
          _currentSubscription = null;
          print('[ChatService] 이전 구독 해제 완료.');

          // 새 구독 등록
          final destination = '/topic/chat/room/$chatRoomId';
          print('[ChatService] 새 구독 시작 -> $destination');
          _currentSubscription = _stompClient!.subscribe(
            destination: destination,
            callback: (StompFrame frame) {
              print('[ChatService] 새 메시지 수신: ${frame.body}');
              if (frame.body != null) {
                try {
                  final data = jsonDecode(frame.body!);
                  _messageStreamController.add(
                    ChatMessageDto.fromJson(data as Map<String, dynamic>),
                  );
                } catch (e) {
                  print('[ChatService] !!!!! 메시지 파싱 오류 !!!!!: $e');
                }
              }
            },
          );
        },
        onWebSocketError: (err) =>
            print('[ChatService] !!!!! 웹소켓 오류 !!!!!: $err'),
        onStompError: (frame) =>
            print('[ChatService] !!!!! STOMP 프로토콜 오류 !!!!!: ${frame.body}'),
        onDisconnect: (_) {
          print('[ChatService] STOMP 연결 끊김. Room: $chatRoomId');
          _currentSubscription?.call();
          _currentSubscription = null;
        },
        onDebugMessage: (String message) => print('[STOMP DEBUG] $message'),
      ),
    );

    _stompClient!.activate();
    print('[ChatService] StompClient 활성화.');
  }

  // STOMP 메시지 전송
  void sendStompChatMessage(ChatMessageDto message) {
    if (_stompClient == null || !_stompClient!.connected) {
      print('[ChatService] STOMP 연결 안됨. 메시지 전송 실패.');
      return;
    }
    final destination = '/app/chat/room/${message.chatRoomId}';
    print('[ChatService] 메시지 전송 시도 -> $destination, 내용: ${message.message}');
    _stompClient!.send(
      destination: destination,
      body: jsonEncode(message.toJson()),
    );
    print('[ChatService] 메시지 전송 완료: ${message.message}');
  }

  // 연결 해제
  void disconnectStomp() {
    print('[ChatService] STOMP 연결 해제 요청.');
    _currentSubscription?.call();
    _currentSubscription = null;
    _stompClient?.deactivate();
    _stompClient = null;
    print('[ChatService] STOMP 연결 해제 완료.');
  }

  void dispose() {
    print("[ChatService] dispose 호출됨. 스트림 닫고 연결 해제.");
    disconnectStomp();
    _messageStreamController.close();
  }
}
