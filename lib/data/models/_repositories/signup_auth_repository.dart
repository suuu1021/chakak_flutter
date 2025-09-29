import 'package:dio/dio.dart';
import '../../../../data/dtos/auth_dto.dart';

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
