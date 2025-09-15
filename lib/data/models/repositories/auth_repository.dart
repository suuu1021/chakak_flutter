import 'package:dio/dio.dart';
import '../../dtos/auth_dto.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {'Content-Type': 'application/json'},
        ));

  // (선택) 로그인 이후 헤더에 토큰 자동 추가하고 싶을 때 사용
  void setAuthHeader({required String tokenType, required String accessToken}) {
    _dio.options.headers['Authorization'] = '$tokenType $accessToken';
  }

  /// [일반 로그인] /api/users/login
  /// 백엔드: ApiUtil로 감싸질 수 있음 -> {"data": {...}}
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final res = await _dio.post('/api/users/login', data: request.toJson());

      final raw = res.data;
      final data =
          (raw is Map && raw['response'] != null) ? raw['response'] : raw;

      final parsed = LoginResponse.fromJson(data);

      if (parsed.tokenType.isNotEmpty && parsed.accessToken.isNotEmpty) {
        setAuthHeader(
            tokenType: parsed.tokenType, accessToken: parsed.accessToken);
      }
      return parsed;
    } on DioException catch (e) {
      // ✅ 여기 디버깅용 로그 추가
      print("DioException 발생: ${e.type}, ${e.message}");
      if (e.response != null) {
        print("응답 상태코드: ${e.response?.statusCode}");
        print("응답 바디: ${e.response?.data}");
      } else {
        print("서버 응답 없음 (네트워크 문제일 가능성 높음)");
      }

      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception('로그인 실패 ($status): $body');
    }
  }

  /// [카카오 로그인] /api/auth/kakao/login
  /// 응답: { "jwt": "...", "email": "..." }
  Future<SocialLoginResponse> kakaoLogin(SocialLoginRequest request) async {
    try {
      final res =
          await _dio.post('/api/auth/kakao/login', data: request.toJson());
      final parsed = SocialLoginResponse.fromJson(res.data);
      // Kakao는 jwt만 내려오므로, 필요 시 setAuthHeader로 싱크 맞출 수 있음
      // setAuthHeader(tokenType: "Bearer", accessToken: parsed.jwt);
      return parsed;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception('카카오 로그인 실패 ($status): $body');
    }
  }
}
