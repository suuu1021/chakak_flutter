import 'package:dio/dio.dart';

class AuthService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://localhost:8080", // 👉 백엔드 서버 주소로 변경 필요
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {"Content-Type": "application/json"},
  ));

  static Future<String> login(String email, String password) async {
    final response = await _dio.post("/auth/login", data: {
      "email": email,
      "password": password,
    });

    if (response.statusCode == 200) {
      // ✅ JWT 토큰 반환
      return response.data["token"];
    } else {
      throw Exception("로그인 실패: ${response.statusCode}");
    }
  }
}
