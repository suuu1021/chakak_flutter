
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/core/dio_provider.dart';
import '../../dtos/auth_dto.dart';

// ✅ 1. [신설] 올바르게 설정된 Dio 객체를 주입하여 AuthRepository를 생성하는 Provider.
// 앞으로 앱의 모든 곳에서는 이 Provider를 통해 Repository를 사용해야 합니다.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // dioProvider를 읽어와서 올바르게 설정된 Dio 객체를 가져옵니다.
  final dio = ref.read(dioProvider); 
  return AuthRepository(dio);
});

class AuthRepository {
  // ✅ 2. [수정] final로 변경. 이제 외부에서 Dio 인스턴스를 주입받습니다.
  final Dio _dio;

  // ✅ 3. [수정] 생성자가 Dio 인스턴스를 직접 받도록 변경되었습니다.
  // 이제 Repository는 Dio 설정에 대해 전혀 알지 못하며, 단지 사용만 합니다.
  AuthRepository(this._dio) {
    print("[AuthRepository] 생성 완료. 외부로부터 받은 Dio 인스턴스를 사용합니다.");
  }

  // Interceptor가 토큰을 관리하므로 이 함수는 더 이상 필요하지 않습니다.
  // void setAuthHeader(...) { ... }

  /// [일반 로그인] /api/users/login
  Future<LoginResponse> login(LoginRequest request) async {
    // ✅ 4. [수정] 상세한 로그와 에러 처리를 추가합니다.
    print("[AuthRepository] login() 호출됨. API POST 요청 시도 -> /api/users/login");
    try {
      final res = await _dio.post('/api/users/login', data: request.toJson());
      print("[AuthRepository] API 응답 성공! Raw data: ${res.data}");

      // 이전 수정에서 적용된 'body' 파싱 로직을 유지합니다.
      final body = res.data['body'];
      if (body == null) {
        print("[AuthRepository] !!!!! 에러: 서버 응답에 'body' 필드가 없습니다.");
        throw Exception("서버 응답에 'body' 필드가 없습니다.");
      }
      print("[AuthRepository] 파싱할 데이터 추출 (body): $body");
      
      final parsed = LoginResponse.fromJson(body);
      print("[AuthRepository] 데이터 파싱 성공. LoginResponse 객체 생성 완료.");

      // Interceptor가 토큰을 자동으로 추가하므로, 여기서 헤더를 수동으로 설정하는 코드는 삭제합니다.
      return parsed;

    } on DioException catch (e) {
      // Dio 관련 에러를 더 상세하게 로깅합니다.
      print("[AuthRepository] !!!!! DioException 발생 !!!!!");
      print("  - Type: ${e.type}");
      print("  - Message: ${e.message}");
      print("  - Request Path: ${e.requestOptions.path}");
      print("  - Response Data: ${e.response?.data}");
      throw Exception('로그인 API 호출 실패: ${e.message}');
    } catch (e) {
      print("[AuthRepository] !!!!! 파싱 또는 기타 에러 !!!!!: $e");
      rethrow; // 에러를 AuthProvider로 다시 던짐
    }
  }

  /// [카카오 로그인] /api/auth/kakao/login
  Future<SocialLoginResponse> kakaoLogin(SocialLoginRequest request) async {
    // ... 카카오 로그인 로직은 일단 그대로 둡니다 ...
    final res = await _dio.post('/api/auth/kakao/login', data: request.toJson());
    return SocialLoginResponse.fromJson(res.data);
  }
}
