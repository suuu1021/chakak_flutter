import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/core/dio_provider.dart';
import '../../dtos/auth_dto.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio) {
    print("[AuthRepository] 생성 완료. 외부로부터 받은 Dio 인스턴스를 사용합니다.");
  }

  Future<LoginResponse> login(LoginRequest request) async {
    print("[AuthRepository] login() 호출됨. API POST 요청 시도 -> /api/users/login");
    try {
      final res = await _dio.post('/api/users/login', data: request.toJson());
      print("[AuthRepository] API 응답 성공! Raw data: ${res.data}");

      final body = res.data['body'];
      if (body == null) {
        print("[AuthRepository] !!!!! 에러: 서버 응답에 'body' 필드가 없습니다.");
        throw Exception("서버 응답에 'body' 필드가 없습니다.");
      }
      print("[AuthRepository] 파싱할 데이터 추출 (body): $body");

      final parsed = LoginResponse.fromJson(body);
      print("[AuthRepository] 데이터 파싱 성공. LoginResponse 객체 생성 완료.");

      return parsed;

    } on DioException catch (e) {
      print("[AuthRepository] !!!!! DioException 발생 !!!!!");
      print("  - Type: ${e.type}");
      print("  - Message: ${e.message}");
      print("  - Request Path: ${e.requestOptions.path}");
      print("  - Response Data: ${e.response?.data}");
      throw Exception('로그인 API 호출 실패: ${e.message}');
    } catch (e) {
      print("[AuthRepository] !!!!! 파싱 또는 기타 에러 !!!!!: $e");
      rethrow;
    }
  }

  Future<SocialLoginResponse> kakaoLogin(SocialLoginRequest request) async {
    final res = await _dio.post('/api/auth/kakao/login', data: request.toJson());
    return SocialLoginResponse.fromJson(res.data);
  }
}
