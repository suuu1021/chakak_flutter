import 'package:dio/dio.dart';

import '../data/dtos/user_profile_dto.dart';

class UserProfileService {
  final Dio _dio;

  UserProfileService(this._dio);

  // 응답 데이터 추출 헬퍼 메서드
  T _extractResponseData<T>(Response response, T Function(dynamic) parser) {
    final responseData = response.data;

    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return parser(responseData['data']);
    }

    return parser(responseData);
  }

  // 사용자 프로필 생성
  Future<UserProfileDto> createProfile(
      UserProfileCreateRequestDto request) async {
    try {
      final response = await _dio.post(
        '/api/user-profile/create',
        data: request.toJson(),
      );

      return _extractResponseData<UserProfileDto>(
        response,
        (data) => UserProfileDto.fromJson(data),
      );
    } on DioException catch (e) {
      throw Exception('프로필 생성 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('프로필 생성 실패: $e');
    }
  }

  // 사용자 프로필 조회 (현재 로그인된 사용자)
  Future<UserProfileDto> getMyProfile() async {
    try {
      final response = await _dio.get('/api/user-profile/my');

      return _extractResponseData<UserProfileDto>(
        response,
        (data) => UserProfileDto.fromJson(data),
      );
    } on DioException catch (e) {
      throw Exception('프로필 조회 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('프로필 조회 실패: $e');
    }
  }

  // 사용자 프로필 수정
  Future<UserProfileDto> updateProfile(
      UserProfileUpdateRequestDto request) async {
    try {
      final response = await _dio.put(
        '/api/user-profile/update',
        data: request.toJson(),
      );

      return _extractResponseData<UserProfileDto>(
        response,
        (data) => UserProfileDto.fromJson(data),
      );
    } on DioException catch (e) {
      throw Exception('프로필 수정 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('프로필 수정 실패: $e');
    }
  }

  // 닉네임 중복 체크
  Future<bool> checkNicknameDuplicate(String nickname) async {
    try {
      final response = await _dio.get(
        '/api/user-profile/check-nickname',
        queryParameters: {'nickname': nickname},
      );

      return _extractResponseData<bool>(
        response,
        (data) => data['available'] ?? false,
      );
    } on DioException catch (e) {
      throw Exception('닉네임 중복 체크 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('닉네임 중복 체크 실패: $e');
    }
  }
}
