import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../dtos/booking/booking_request_dto.dart';
import '../../dtos/booking/booking_detail_dto.dart';
import '../../dtos/booking/booking_dto.dart';

class BookingRepository {
  late http.Client _client;
  String? _authToken;

  static String get serverUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.0.82:8080';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  bool get isAuthenticated => _authToken != null;

  void Function()? onAuthRequired;
  void Function(String error)? onNetworkError;
  void Function()? onBookingCreated;
  void Function()? onBookingCanceled;

  void init() {
    _client = http.Client();
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(dynamic) parser,
    String operation,
  ) {
    try {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
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
      print('Error in $operation: $e');
      onNetworkError?.call('$operation 실패: $e');
      rethrow;
    }
  }

  // 실제 백엔드 응답 구조에 맞게 수정된 파싱 로직
  List<T> _parseListResponse<T>(
      dynamic jsonData, T Function(Map<String, dynamic>) fromJson) {
    try {
      print('Parsing response: $jsonData');

      // 실제 백엔드 응답 구조: { "status": 200, "msg": "성공", "body": [...] }
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('body')) {
        final dynamic bodyField = jsonData['body'];

        if (bodyField is List) {
          return bodyField
              .cast<Map<String, dynamic>>()
              .map((item) => fromJson(item))
              .toList();
        }
      }

      // ApiUtil<> 래핑 구조: { "data": [...] } (fallback)
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
        final dynamic dataField = jsonData['data'];

        if (dataField is List) {
          return dataField
              .cast<Map<String, dynamic>>()
              .map((item) => fromJson(item))
              .toList();
        }
      }

      // 직접 리스트인 경우 (fallback)
      if (jsonData is List) {
        return jsonData
            .cast<Map<String, dynamic>>()
            .map((item) => fromJson(item))
            .toList();
      }

      print('Unexpected response format: $jsonData');
      throw Exception('예상치 못한 응답 형식입니다: ${jsonData.runtimeType}');
    } catch (e) {
      print('Parse error: $e');
      rethrow;
    }
  }

  // 수정된 API 엔드포인트 - 백엔드와 일치
  Future<List<BookingDto>> getUserBookingList(int userId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      print('Fetching user booking list...');

      // 백엔드 엔드포인트에 맞게 수정: /api/v1/bookings/user/my-list
      final response = await _client
          .get(
            Uri.parse(
                '$serverUrl/api/v1/bookings/user/my-list'), // userId 파라미터 제거
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(
          response,
          (jsonData) => _parseListResponse(jsonData, BookingDto.fromJson),
          '사용자 예약 목록 조회');
    } catch (e) {
      print('getUserBookingList error: $e');
      throw Exception('사용자 예약 목록 조회 실패: $e');
    }
  }

  // 수정된 API 엔드포인트 - 백엔드와 일치
  Future<List<BookingDto>> getPhotographerBookingList(int userId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      print('Fetching photographer booking list...');

      // 백엔드 엔드포인트에 맞게 수정: /api/v1/bookings/photographer/my-list
      final response = await _client.get(
        Uri.parse(
            '$serverUrl/api/v1/bookings/photographer/my-list'), // userId 파라미터 제거
        headers: _getHeaders(),
      );

      return _handleResponse(
          response,
          (jsonData) => _parseListResponse(jsonData, BookingDto.fromJson),
          '포토그래퍼 예약 목록 조회');
    } catch (e) {
      print('getPhotographerBookingList error: $e');
      throw Exception('포토그래퍼 예약 목록 조회 실패: $e');
    }
  }

  // 수정된 API 엔드포인트 - 백엔드와 일치
  Future<BookingDetailDto> getBookingDetail(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      // 백엔드 엔드포인트에 맞게 수정: /api/v1/bookings/{bookingInfoId}
      final response = await _client.get(
        Uri.parse('$serverUrl/api/v1/bookings/$bookingInfoId'),
        headers: _getHeaders(),
      );

      return _handleResponse(response, (jsonData) {
        // ApiUtil 래핑 구조 처리
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is Map<String, dynamic>) {
              return BookingDetailDto.fromJson(data);
            }
          }
          // 직접 BookingDetailDto 필드가 있는 경우 (fallback)
          if (jsonData.containsKey('photographerProfileId')) {
            return BookingDetailDto.fromJson(jsonData);
          }
        }
        throw Exception('예상치 못한 응답 형식입니다');
      }, '예약 상세 조회');
    } catch (e) {
      throw Exception('예약 상세 조회 실패: $e');
    }
  }

  // 수정된 API 엔드포인트 - 백엔드와 일치
  Future<void> createBooking(BookingCreateRequestDto request) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      // 백엔드 엔드포인트에 맞게 수정: /api/v1/bookings (POST)
      final response = await _client.post(
        Uri.parse('$serverUrl/api/v1/bookings'),
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

  // 수정된 API 엔드포인트 - 백엔드와 일치 (PATCH)
  Future<void> cancelBooking(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      // PUT에서 PATCH로 변경, 엔드포인트 수정
      final response = await _client.patch(
        Uri.parse('$serverUrl/api/v1/bookings/$bookingInfoId/cancel'),
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

  // 수정된 API 엔드포인트 - 백엔드와 일치 (PATCH)
  Future<void> confirmBooking(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      // PUT에서 PATCH로 변경, 엔드포인트 수정
      final response = await _client.patch(
        Uri.parse('$serverUrl/api/v1/bookings/$bookingInfoId/confirm'),
        headers: _getHeaders(),
      );

      _handleResponse(response, (jsonData) => null, '예약 승인');
    } catch (e) {
      throw Exception('예약 승인 실패: $e');
    }
  }

  Future<void> rejectBooking(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      // 백엔드에 reject 엔드포인트가 없는 것 같으니 cancel을 사용
      final response = await _client.patch(
        Uri.parse('$serverUrl/api/v1/bookings/$bookingInfoId/cancel'),
        headers: _getHeaders(),
      );

      _handleResponse(response, (jsonData) => null, '예약 거절');
    } catch (e) {
      throw Exception('예약 거절 실패: $e');
    }
  }

  // 수정된 API 엔드포인트 - 백엔드와 일치 (PATCH)
  Future<void> completeBooking(int bookingInfoId) async {
    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      // PUT에서 PATCH로 변경, 엔드포인트 수정
      final response = await _client.patch(
        Uri.parse('$serverUrl/api/v1/bookings/$bookingInfoId/complete'),
        headers: _getHeaders(),
      );

      _handleResponse(response, (jsonData) => null, '촬영 완료 처리');
    } catch (e) {
      throw Exception('촬영 완료 처리 실패: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
