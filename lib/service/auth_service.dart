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

  Future<String> socialLogin(
      String provider, String code, String typeCode) async {
    try {
      final response = await _dio.post(
        "/api/auth/$provider/login",
        data: {"code": code, "typeCode": typeCode},
      );
      return response.data["jwt"];
    } on DioException catch (e) {
      throw Exception(
          "$provider 로그인 실패: ${e.response?.data['msg'] ?? '알 수 없는 오류가 발생했습니다.'}");
    }
  }
}
