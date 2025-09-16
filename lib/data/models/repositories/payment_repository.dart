import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../dtos/payment/payment_dto.dart';
import '../../dtos/payment/payment_requenst_dto.dart';
import '../../dtos/payment/payment_response_dto.dart';

class PaymentRepository {
  late http.Client _client;
  String? _authToken;

  // 플랫폼별 서버 주소 설정
  static String get serverUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.0.82:8080';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  // 인증 토큰 설정 메서드
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // 인증 토큰 확인 getter
  bool get isAuthenticated => _authToken != null;

  // 콜백 함수들
  void Function()? onAuthRequired;
  void Function(String error)? onNetworkError;

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
      onNetworkError?.call('$operation 실패: $e');
      rethrow;
    }
  }

  // 결제 준비
  Future<PaymentReadyResponseDto> paymentReady(int bookingInfoId) async {
    print('=== 결제 준비 API 호출 ===');
    print('URL: $serverUrl/api/payment/ready');
    print('인증됨: $isAuthenticated');

    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final request = PaymentReadyRequestDto(bookingInfoId: bookingInfoId);

      final response = await _client
          .post(
            Uri.parse('$serverUrl/api/payment/ready'),
            headers: _getHeaders(),
            body: json.encode(request.toJson()),
          )
          .timeout(Duration(seconds: 10));

      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');

      return _handleResponse(response, (jsonData) {
        return PaymentReadyResponseDto.fromJson(jsonData);
      }, '결제 준비');
    } catch (e) {
      print('에러 발생: $e');
      throw Exception('결제 준비 실패: $e');
    }
  }

  // 사용자 결제 내역 조회
  Future<List<PaymentDto>> getUserPayments(
      {int page = 0, int size = 10}) async {
    print('=== 결제 내역 API 호출 ===');
    print('URL: $serverUrl/api/payment/user/payments?page=$page&size=$size');
    print('인증됨: $isAuthenticated');

    if (!isAuthenticated) {
      onAuthRequired?.call();
      throw Exception('로그인이 필요합니다');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('$serverUrl/api/payment/user?page=$page&size=$size'),
            headers: _getHeaders(),
          )
          .timeout(Duration(seconds: 10));

      print('응답 상태: ${response.statusCode}');
      print('응답 내용: ${response.body}');

      return _handleResponse(response, (jsonData) {
        print('파싱할 JSON: $jsonData');

        // 백엔드 응답 구조: {status, msg, body: {content: [...], page, size, ...}}
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('body') && jsonData['body'] != null) {
            final body = jsonData['body'] as Map<String, dynamic>;
            if (body.containsKey('content')) {
              final List<dynamic> content = body['content'];
              print('결제 데이터 길이: ${content.length}');
              return content.map((item) => PaymentDto.fromJson(item)).toList();
            }
          }
        }

        // 직접 배열인 경우
        if (jsonData is List) {
          print('배열 형태 응답, 길이: ${jsonData.length}');
          return jsonData.map((item) => PaymentDto.fromJson(item)).toList();
        }

        return <PaymentDto>[];
      }, '결제 내역 조회');
    } catch (e) {
      print('에러 발생: $e');
      throw Exception('결제 내역 조회 실패: $e');
    }
  }

  // 리소스 해제
  void dispose() {
    _client.close();
  }
}
