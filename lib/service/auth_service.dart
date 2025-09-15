// lib/service/auth_service.dart

import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      // ✅ [수정] 올바른 경로에서 토큰을 추출합니다.
      // response.data["token"] -> response.data["body"]["accessToken"]
      final String? accessToken = response.data["body"]["accessToken"];
      if (accessToken == null) {
        throw Exception("서버 응답에 accessToken이 없습니다.");
      }
      return accessToken;

    } on DioException catch (e) {
      throw Exception("로그인 실패: ${e.response?.data['msg'] ?? '알 수 없는 오류'}");
    } catch (e) {
      // accessToken이 null인 경우 등 다른 예외 처리
      throw Exception("로그인 처리 중 오류가 발생했습니다: $e");
    }
  }

  // ... socialLogin 함수는 그대로 ...
  Future<String> socialLogin(String provider, String code, String typeCode) async {
    try {
      final response = await _dio.post(
        "/api/auth/$provider/login",
        data: {"code": code, "typeCode": typeCode},
      );
      // 이전 코드에서 "jwt" 키를 사용했으므로, 이를 유지합니다.
      return response.data["jwt"];
    } on DioException catch (e) {
      throw Exception("$provider 로그인 실패: ${e.response?.data['msg'] ?? '알 수 없는 오류가 발생했습니다.'}");
    }
  }
}
