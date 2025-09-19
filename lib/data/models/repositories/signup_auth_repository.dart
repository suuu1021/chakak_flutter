import 'package:dio/dio.dart';
// flutter_riverpod import는 Provider 정의를 제거하므로 더 이상 필요하지 않을 수 있습니다.
// 만약 다른 이유로 필요하다면 유지합니다. 여기서는 일단 제거하지 않겠습니다.
import 'package:flutter_riverpod/flutter_riverpod.dart';

// auth_dto.dart 파일의 DTO들을 가져오기 위한 import
import '../../../../data/dtos/auth_dto.dart';
// dio_provider.dart 파일의 dioProvider를 가져오기 위한 import
// 이 import는 Repository가 직접 Provider를 참조하지 않는다면 필요 없을 수 있습니다.
// 하지만 Dio 인스턴스를 생성자에서 받으므로, Provider를 정의하는 측에서 필요합니다.
// Repository 자체는 dio 인스턴스만 알면 됩니다.
// import '../../provider/core/dio_provider.dart'; // Repository 파일에서는 직접적인 Provider 참조 제거 고려

class SignupAuthRepository {
  final Dio _dio;

  SignupAuthRepository(this._dio);

  Future<RegisterResponse> register(RegisterRequest request) async {
    const String endpoint = "/api/users/signup";

    try {
      final response = await _dio.post(
        endpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return RegisterResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: '회원가입은 되었으나 서버 응답 코드가 예상과 다릅니다: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = '회원가입 중 오류가 발생했습니다.';
      if (e.response != null && e.response?.data != null) {
        errorMessage =
            '서버 오류 (${e.response?.statusCode}): ${e.response?.data.toString()}';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = '네트워크 연결 시간을 초과했습니다.';
      } else if (e.type == DioExceptionType.cancel) {
        errorMessage = '요청이 취소되었습니다.';
      } else {
        errorMessage = '네트워크 또는 서버 오류: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('회원가입 처리 중 알 수 없는 오류 발생: $e');
    }
  }
}
