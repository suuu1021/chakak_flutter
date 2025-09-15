import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';


import '../data/dtos/chat_room_create_request_dto.dart';
import '../data/dtos/chat_room_response_dto.dart';
import '../data/dtos/chat_message_dto.dart';
import '../data/dtos/chat_room_list_item_dto.dart';

class ChatService {
  final Dio _dio;
  final String _apiBaseUrl = ""; //TODO 추후 추가하기
  final String stompConnectUrl = 'ws://localhost:8080/ws';

  StompClient? _stompClient;
  StompUnsubscribe? _currentSubscription; //
  final _messageStreamController = StreamController<ChatMessageDto>.broadcast();

  Stream<ChatMessageDto> get messages => _messageStreamController.stream;

  ChatService(this._dio);

  // 채팅방 생성 및 조회
  Future<ChatRoomResponseDto> createOrGetChatRoom(ChatRoomCreateRequestDto requestDto) async {
    try {
      final response = await _dio.post(
        '$_apiBaseUrl/api/chat/rooms',
        data: requestDto.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatRoomResponseDto.fromJson(response.data);
      } else {
        throw Exception('채팅방 생성 또는 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('채팅방 생성/조회 실패: ${e.message}');
    }
  }

  // 채팅방 메시지 조회
  Future<List<ChatMessageDto>> getMessagesByRoomId(int chatRoomId) async {
    try {
      final response = await _dio.get('$_apiBaseUrl/api/chat/rooms/$chatRoomId/messages');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data as List<dynamic>;
        return responseData.map((e) => ChatMessageDto.fromJson(e)).toList();
      } else {
        throw Exception('메시지 목록 불러오기 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('메시지 목록 불러오기 실패: ${e.message}');
    }
  }

  // 메시지 읽음 처리
  Future<void> markMessagesAsRead(int chatRoomId) async {
    try {
      final response = await _dio.post('$_apiBaseUrl/api/chat/rooms/$chatRoomId/read');
      if (response.statusCode != 200) {
        throw Exception('메시지 읽음 처리 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('메시지 읽음 처리 실패: ${e.message}');
    }
  }

  // 내 채팅방 목록 조회
  Future<List<ChatRoomListItemDto>> getMyChatRooms() async {
    try {
      final response = await _dio.get('$_apiBaseUrl/api/chat/my/rooms');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data as List<dynamic>;
        return responseData.map((e) => ChatRoomListItemDto.fromJson(e)).toList();
      } else {
        throw Exception('내 채팅방 목록 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('내 채팅방 목록 조회 실패: ${e.message}');
    }
  }

  // STOMP 연결
  Future<void> connectStomp(int chatRoomId, String jwtToken) async {
    if (_stompClient != null && _stompClient!.connected) {
      print('이미 연결된 상태입니다. Room: $chatRoomId');
      return;
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: stompConnectUrl,
        stompConnectHeaders: {
          'Authorization': 'Bearer $jwtToken',
        },
        onConnect: (StompFrame frame) {
          print('STOMP 연결 성공! Room: $chatRoomId');

          // 이전 구독 해제
          _currentSubscription?.call();
          _currentSubscription = null;

          // 새 구독 등록
          _currentSubscription = _stompClient!.subscribe(
            destination: '/sub/chat/room/$chatRoomId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  final data = jsonDecode(frame.body!);
                  _messageStreamController.add(
                    ChatMessageDto.fromJson(data as Map<String, dynamic>),
                  );
                } catch (e) {
                  print('메시지 파싱 오류: $e');
                }
              }
            },
          );
        },
        onWebSocketError: (err) => print('웹소켓 오류: $err'),
        onStompError: (frame) => print('STOMP 프로토콜 오류: ${frame.body}'),
        onDisconnect: (_) {
          print('STOMP 연결 끊김');
          _currentSubscription?.call();
          _currentSubscription = null;
        },
      ),
    );

    _stompClient!.activate();
  }

  // STOMP 메시지 전송
  void sendStompChatMessage(ChatMessageDto message, int chatRoomId) {
    if (_stompClient == null || !_stompClient!.connected) {
      print('STOMP 연결 안됨');
      return;
    }
    final destination = '/app/chat/room/$chatRoomId';
    _stompClient!.send(
      destination: destination,
      body: jsonEncode(message.toJson()),
    );
    print('메시지 전송 완료: ${message.message}');
  }

  // 연결 해제
  void disconnectStomp() {
    print('STOMP 연결 해제');
    _currentSubscription?.call();
    _currentSubscription = null;
    _stompClient?.deactivate();
    _stompClient = null;
  }

  void dispose() {
    disconnectStomp();
    _messageStreamController.close();
  }
}
