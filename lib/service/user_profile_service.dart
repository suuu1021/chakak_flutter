import 'package:dio/dio.dart';
import '../data/dtos/user_profile_dto.dart';

class UserProfileService {
  final Dio _dio;

  UserProfileService(this._dio);

  T _extractResponseData<T>(Response response, T Function(dynamic) parser) {
    final responseData = response.data;
    if (responseData is Map<String, dynamic> && responseData.containsKey('body')) {
      return parser(responseData['body']);
    }
    return parser(responseData);
  }

  Future<UserProfileDto> createProfile(UserProfileCreateRequestDto request) async {
    try {
      final response = await _dio.post('/api/user-profile/create', data: request.toJson());
      return _extractResponseData(response, (data) => UserProfileDto.fromJson(data));
    } on DioException catch (e) {
      throw Exception('프로필 생성 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('프로필 생성 실패: $e');
    }
  }

  Future<UserProfileDto> getMyProfile() async {
    try {
      final response = await _dio.get('/api/v1/users/profile/detail');
      return _extractResponseData(response, (data) => UserProfileDto.fromJson(data));
    } on DioException catch (e) {
      throw Exception('프로필 조회 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('프로필 조회 실패: $e');
    }
  }

  // 1. 반환 타입을 Future<void>로 변경하고, 응답 파싱 로직 제거
  Future<void> updateProfile(UserProfileUpdateRequestDto request) async {
    try {
      await _dio.put('/api/v1/users/profile/update', data: request.toJson());
    } on DioException catch (e) {
      throw Exception('프로필 수정 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('프로필 수정 실패: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete('/api/users/delete/$userId');
    } on DioException catch (e) {
      throw Exception('회원 탈퇴 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('회원 탈퇴 실패: $e');
    }
  }

  Future<bool> checkNicknameDuplicate(String nickname) async {
    try {
      final response = await _dio.get('/api/user-profile/check-nickname', queryParameters: {'nickname': nickname});
      return _extractResponseData(response, (data) => data['available'] ?? false);
    } on DioException catch (e) {
      throw Exception('닉네임 중복 체크 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('닉네임 중복 체크 실패: $e');
    }
  }
}
