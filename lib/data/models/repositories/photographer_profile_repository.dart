import 'package:dio/dio.dart';

import '../../dtos/photographer_profile_dto.dart';
import '../photographer_profile.dart';

/// 사진작가 프로필 관련 Repository 인터페이스
abstract class PhotographerProfileRepository {
  /// 프로필 생성
  Future<PhotographerProfile> createProfile(PhotographerProfileFormDto dto);

  /// 프로필 수정
  Future<PhotographerProfile> updateProfile(
      String id, PhotographerProfileFormDto dto);

  /// 특정 프로필 조회
  Future<PhotographerProfile?> getProfile(String id);

  /// 내 프로필 조회 (현재 로그인 사용자)
  Future<PhotographerProfile?> getMyProfile();

  /// 프로필 삭제
  Future<void> deleteProfile(String id);

  /// 프로필 상태 변경 (활성/비활성)
  Future<void> updateProfileStatus(String id, String status);
}

/// 사진작가 프로필 Repository 구현체
class PhotographerProfileRepositoryImpl
    implements PhotographerProfileRepository {
  final Dio _dio;

  PhotographerProfileRepositoryImpl(this._dio);

  @override
  Future<PhotographerProfile> createProfile(
      PhotographerProfileFormDto dto) async {
    try {
      // TODO: 실제 API 호출로 교체
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock 응답 시뮬레이션
      final now = DateTime.now();
      final mockResponse = {
        'id': 'profile_${now.millisecondsSinceEpoch}',
        'businessName': dto.businessName,
        'introduction': dto.introduction,
        'location': dto.location,
        'experienceYears': dto.experienceYears,
        'status': dto.status,
        'profileImageUrl': dto.profileImageUrl,
        'createdAt': now.toIso8601String(),
        'updatedAt': null,
      };

      return PhotographerProfile.fromJson(mockResponse);
    } catch (e) {
      throw Exception('프로필 생성에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<PhotographerProfile> updateProfile(
      String id, PhotographerProfileFormDto dto) async {
    try {
      // TODO: 실제 API 호출로 교체
      await Future.delayed(const Duration(milliseconds: 600));

      // Mock 응답 시뮬레이션
      final now = DateTime.now();
      final mockResponse = {
        'id': id,
        'businessName': dto.businessName,
        'introduction': dto.introduction,
        'location': dto.location,
        'experienceYears': dto.experienceYears,
        'status': dto.status,
        'profileImageUrl': dto.profileImageUrl,
        'createdAt': '2024-01-01T00:00:00.000Z', // 기존 생성일
        'updatedAt': now.toIso8601String(),
      };

      return PhotographerProfile.fromJson(mockResponse);
    } catch (e) {
      throw Exception('프로필 수정에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<PhotographerProfile?> getProfile(String id) async {
    try {
      print('[DEBUG] 포토그래퍼 프로필 조회 API 호출 시작');
      print('[DEBUG] 요청 URL: /api/photographers/$id');
      print('[DEBUG] DIO 기본 헤더: ${_dio.options.headers}');

      // 서버 API 호출: GET /api/photographers/{id}
      final response = await _dio.get('/api/photographers/$id');

      print('[DEBUG] 응답 상태 코드: ${response.statusCode}');
      print('[DEBUG] 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        // 서버 응답 구조에 따라 조정 필요
        final data =
            response.data['response'] ?? response.data['body'] ?? response.data;

        if (data != null) {
          print('[DEBUG] 파싱할 프로필 데이터: $data');
          return PhotographerProfile.fromJson(data);
        } else {
          print('[DEBUG] 응답 데이터가 null입니다');
          return null;
        }
      }

      print('[DEBUG] 예상치 못한 응답 코드: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('[DEBUG] DioException 발생');
      print('[DEBUG] 상태 코드: ${e.response?.statusCode}');
      print('[DEBUG] 응답 데이터: ${e.response?.data}');
      print('[DEBUG] 에러 메시지: ${e.message}');

      if (e.response?.statusCode == 404) {
        // 포토그래퍼 프로필이 없는 경우
        print('[DEBUG] 포토그래퍼 프로필을 찾을 수 없음 (404)');
        return null;
      } else if (e.response?.statusCode == 403) {
        print('[DEBUG] 접근 권한 없음 (403)');
        throw Exception('해당 포토그래퍼 프로필에 접근할 권한이 없습니다');
      } else if (e.response?.statusCode == 401) {
        print('[DEBUG] 인증 만료 (401)');
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요');
      } else {
        print('[DEBUG] 기타 HTTP 에러: ${e.response?.statusCode}');
        throw Exception('프로필 조회 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      print('[DEBUG] 일반 예외 발생: $e');
      throw Exception('포토그래퍼 프로필 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<PhotographerProfile?> getMyProfile() async {
    try {
      print('[DEBUG] 포토그래퍼 프로필 API 호출 시작');
      print('[DEBUG] 요청 URL: /api/photographers/me');
      print('[DEBUG] DIO 기본 헤더: ${_dio.options.headers}');

      // 서버 API 호출: GET /api/photographers/me
      final response = await _dio.get('/api/photographers/me');
      print('[DEBUG] 요청 헤더: ${response.requestOptions.headers}');

      print('[DEBUG] 응답 상태 코드: ${response.statusCode}');
      print('[DEBUG] 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        // 서버 응답 구조: { success: true, response: { photographerId: ..., businessName: ... } }
        final data = response.data['response'];

        if (data != null) {
          print('[DEBUG] 파싱할 프로필 데이터: $data');
          return PhotographerProfile.fromJson(data);
        } else {
          print('[DEBUG] 응답 데이터가 null입니다');
          return null;
        }
      }

      print('[DEBUG] 예상치 못한 응답 코드: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('[DEBUG] DioException 발생');
      print('[DEBUG] 상태 코드: ${e.response?.statusCode}');
      print('[DEBUG] 응답 데이터: ${e.response?.data}');
      print('[DEBUG] 에러 메시지: ${e.message}');

      if (e.response?.statusCode == 404) {
        // 등록된 포토그래퍼 프로필이 없는 경우 - 정상적인 상황
        print('[DEBUG] 프로필이 등록되지 않음 (404)');
        return null;
      } else if (e.response?.statusCode == 403) {
        print('[DEBUG] 포토그래퍼 권한 없음 (403)');
        throw Exception('포토그래퍼 권한이 없습니다');
      } else if (e.response?.statusCode == 401) {
        print('[DEBUG] 인증 만료 (401)');
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요');
      } else {
        print('[DEBUG] 기타 HTTP 에러: ${e.response?.statusCode}');
        throw Exception('프로필 조회 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      print('[DEBUG] 일반 예외 발생: $e');
      throw Exception('내 프로필 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProfile(String id) async {
    try {
      // TODO: 실제 API 호출로 교체
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('프로필 삭제에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfileStatus(String id, String status) async {
    try {
      // TODO: 실제 API 호출로 교체
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      throw Exception('프로필 상태 변경에 실패했습니다: ${e.toString()}');
    }
  }
}
// 기존 코드는 그대로 두고, 파일 맨 아래에 추가

/// 시연용 Mock Repository
class MockPhotographerProfileRepositoryImpl
    implements PhotographerProfileRepository {
  @override
  Future<PhotographerProfile> createProfile(
      PhotographerProfileFormDto dto) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    final mockResponse = {
      'photographerId': 1,
      'businessName': dto.businessName,
      'introduction': dto.introduction,
      'location': dto.location,
      'experienceYears': dto.experienceYears,
      'status': 'ACTIVE',
      'profileImageUrl': null,
      'createdAt': now.toIso8601String(),
      'updatedAt': null,
    };

    return PhotographerProfile.fromJson(mockResponse);
  }

  @override
  Future<PhotographerProfile> updateProfile(
      String id, PhotographerProfileFormDto dto) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    final mockResponse = {
      'photographerId': int.tryParse(id) ?? 1,
      'businessName': dto.businessName,
      'introduction': dto.introduction,
      'location': dto.location,
      'experienceYears': dto.experienceYears,
      'status': 'ACTIVE',
      'profileImageUrl': null,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': now.toIso8601String(),
    };

    return PhotographerProfile.fromJson(mockResponse);
  }

  @override
  Future<PhotographerProfile?> getProfile(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return getMyProfile(); // 동일한 더미 데이터 반환
  }

  @override
  Future<PhotographerProfile?> getMyProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockResponse = {
      'photographerId': 1,
      'businessName': '스냅스튜디오',
      'introduction':
          '전문 포토그래퍼입니다. 웨딩, 프로필, 가족사진 전문으로 촬영하고 있습니다. 고객의 소중한 순간을 아름답게 담아드리겠습니다.',
      'location': '서울 강남구',
      'experienceYears': 5,
      'status': 'ACTIVE',
      'profileImageUrl': null, // 이미지 에러 방지
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-15T12:00:00.000Z',
    };

    return PhotographerProfile.fromJson(mockResponse);
  }

  @override
  Future<void> deleteProfile(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> updateProfileStatus(String id, String status) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
