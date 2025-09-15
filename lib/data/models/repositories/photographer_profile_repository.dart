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
      // TODO: 실제 API 호출로 교체
      await Future.delayed(const Duration(milliseconds: 400));

      // Mock 데이터 시뮬레이션
      if (id == 'profile_not_found') {
        return null; // 프로필이 없는 경우
      }

      final mockResponse = {
        'id': id,
        'businessName': '테스트 스튜디오',
        'introduction': '안녕하세요! 전문 사진작가입니다. 고객의 소중한 순간을 아름답게 담아드립니다.',
        'location': '서울 강남구',
        'experienceYears': 5,
        'status': 'active',
        'profileImageUrl': 'https://example.com/profile.jpg',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-15T12:00:00.000Z',
      };

      return PhotographerProfile.fromJson(mockResponse);
    } catch (e) {
      throw Exception('프로필 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<PhotographerProfile?> getMyProfile() async {
    try {
      // TODO: 실제 API 호출로 교체 (인증 토큰 포함)
      await Future.delayed(const Duration(milliseconds: 500));

      // 현재 로그인 사용자의 프로필이 없는 경우
      final hasProfile = DateTime.now().millisecondsSinceEpoch % 2 == 0;
      if (!hasProfile) {
        return null;
      }

      // Mock 내 프로필 데이터
      final mockResponse = {
        'id': 'my_profile_123',
        'businessName': '내 포토 스튜디오',
        'introduction': '감성적이고 자연스러운 사진을 촬영합니다.',
        'location': '서울 홍대',
        'experienceYears': 3,
        'status': 'active',
        'profileImageUrl': 'https://example.com/my_profile.jpg',
        'createdAt': '2023-12-01T00:00:00.000Z',
        'updatedAt': '2024-02-01T10:30:00.000Z',
      };

      return PhotographerProfile.fromJson(mockResponse);
    } catch (e) {
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
