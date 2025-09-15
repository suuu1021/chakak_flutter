// features/booking/data/repository/booking_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../dtos/booking/booking_request_dto.dart';
import '../../dtos/booking_detail_dto.dart';
import '../../dtos/booking_photographer_list_dto.dart';
import '../../dtos/booking_user_list_dto.dart';

class BookingRepository {
  late http.Client _client;
  String? _authToken;

  // 플랫폼별 서버 주소 설정
  static String get serverUrl {
    if (Platform.isAndroid) {
      return 'http://localhost:8080';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  // 인증 토큰 설정
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // 인증 토큰 확인 getter
  bool get isAuthenticated => _authToken != null;

  // 콜백 함수들 - 상위 클래스에 이벤트 알림용
  void Function()? onAuthRequired;
  void Function(String error)? onNetworkError;
  void Function()? onBookingCreated;
  void Function()? onBookingCanceled;

  // HTTP 클라이언트 초기화
  void init() {
    _client = http.Client();
  }

  // 공통 헤더 생성
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // API 응답 처리
  T _handleResponse<T>(
    http.Response response,
    T Function(dynamic) parser,
    String operation,
  ) {
    try {
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return parser(jsonData);
      } else if (response.statusCode == 401) {
        onAuthRequired?.call();
        throw Exception('인증이 필요합니다');
      } else if (response.statusCode == 403) {
        throw Exception('접근 권한이 없습니다');
      } else if (response.statusCode == 404) {
        throw Exception('요청한 데이터를 찾을 수 없습니다');
      } else {
        throw Exception('서버 오류 발생: ${response.statusCode}');
      }
    } catch (e) {
      onNetworkError?.call('$operation 실패: $e');
      rethrow;
    }
  }

  // 사용자 예약 목록 조회
  Future<List<BookingUserListDto>> getUserBookingList(int userId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final response = await _client.get(
        Uri.parse('$serverUrl/api/v1/users/booking/$userId/list'),
        headers: _getHeaders(),
      );

      return _handleResponse(response, (jsonData) {
        // API 응답이 배열인 경우
        if (jsonData is List) {
          return jsonData
              .map((item) => BookingUserListDto.fromJson(item))
              .toList();
        }

        // API 응답이 객체로 감싸진 경우
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          final List<dynamic> dataList = jsonData['data'];
          return dataList
              .map((item) => BookingUserListDto.fromJson(item))
              .toList();
        }

        throw Exception('예상치 못한 응답 형식입니다');
      }, '사용자 예약 목록 조회');
    } catch (e) {
      throw Exception('사용자 예약 목록 조회 실패: $e');
    }
  }

  // 포토그래퍼 예약 목록 조회
  Future<List<BookingPhotographerListDto>> getPhotographerBookingList(
      int userId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final response = await _client.get(
        Uri.parse('$serverUrl/api/v1/users/booking/photographer/$userId/list'),
        headers: _getHeaders(),
      );

      return _handleResponse(response, (jsonData) {
        if (jsonData is List) {
          return jsonData
              .map((item) => BookingPhotographerListDto.fromJson(item))
              .toList();
        }

        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          final List<dynamic> dataList = jsonData['data'];
          return dataList
              .map((item) => BookingPhotographerListDto.fromJson(item))
              .toList();
        }

        throw Exception('예상치 못한 응답 형식입니다');
      }, '포토그래퍼 예약 목록 조회');
    } catch (e) {
      throw Exception('포토그래퍼 예약 목록 조회 실패: $e');
    }
  }

  // 예약 상세 조회
  Future<BookingDetailDto> getBookingDetail(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final response = await _client.get(
        Uri.parse('$serverUrl/api/v1/users/booking/$bookingInfoId/detail'),
        headers: _getHeaders(),
      );

      return _handleResponse(response, (jsonData) {
        if (jsonData is Map<String, dynamic>) {
          // 응답이 직접 객체인 경우
          if (jsonData.containsKey('photographerProfileId')) {
            return BookingDetailDto.fromJson(jsonData);
          }

          // 응답이 data로 감싸진 경우
          if (jsonData.containsKey('data')) {
            return BookingDetailDto.fromJson(jsonData['data']);
          }
        }

        throw Exception('예상치 못한 응답 형식입니다');
      }, '예약 상세 조회');
    } catch (e) {
      throw Exception('예약 상세 조회 실패: $e');
    }
  }

  // 예약 생성
  Future<void> createBooking(BookingCreateRequestDto request) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final response = await _client.post(
        Uri.parse('$serverUrl/api/v1/users/booking/save'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      );

      _handleResponse(response, (jsonData) {
        onBookingCreated?.call();
        return null;
      }, '예약 생성');
    } catch (e) {
      throw Exception('예약 생성 실패: $e');
    }
  }

  // 예약 취소 (사용자)
  Future<void> cancelBooking(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final response = await _client.put(
        Uri.parse('$serverUrl/api/v1/users/booking/$bookingInfoId/user-cancel'),
        headers: _getHeaders(),
      );

      _handleResponse(response, (jsonData) {
        onBookingCanceled?.call();
        return null;
      }, '예약 취소');
    } catch (e) {
      throw Exception('예약 취소 실패: $e');
    }
  }

  // 예약 승인 (포토그래퍼)
  Future<void> confirmBooking(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final response = await _client.put(
        Uri.parse(
            '$serverUrl/api/v1/users/booking/$bookingInfoId/photographer-confirm'),
        headers: _getHeaders(),
      );

      _handleResponse(response, (jsonData) => null, '예약 승인');
    } catch (e) {
      throw Exception('예약 승인 실패: $e');
    }
  }

  // 예약 거절 (포토그래퍼)
  Future<void> rejectBooking(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final response = await _client.put(
        Uri.parse(
            '$serverUrl/api/v1/users/booking/$bookingInfoId/photographer-cancel'),
        headers: _getHeaders(),
      );

      _handleResponse(response, (jsonData) => null, '예약 거절');
    } catch (e) {
      throw Exception('예약 거절 실패: $e');
    }
  }

  // 촬영 완료 처리 (포토그래퍼)
  Future<void> completeBooking(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final response = await _client.put(
        Uri.parse(
            '$serverUrl/api/v1/users/booking/$bookingInfoId/photographer-service-end'),
        headers: _getHeaders(),
      );

      _handleResponse(response, (jsonData) => null, '촬영 완료 처리');
    } catch (e) {
      throw Exception('촬영 완료 처리 실패: $e');
    }
  }

  // 리소스 해제
  void dispose() {
    _client.close();
  }
}
