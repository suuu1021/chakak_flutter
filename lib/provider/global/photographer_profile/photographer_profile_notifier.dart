import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dtos/photographer_profile_dto.dart';
import '../../../data/models/photographer_profile.dart';
import '../../../data/models/repositories/photographer_profile_repository.dart';
import '../../core/dio_provider.dart';

/// 사진작가 프로필 상태
class PhotographerProfileState {
  final PhotographerProfile? profile;
  final bool isLoading;
  final String? errorMessage;
  final bool isEditMode;

  const PhotographerProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.isEditMode = false,
  });

  PhotographerProfileState copyWith({
    PhotographerProfile? profile,
    bool? isLoading,
    String? errorMessage,
    bool? isEditMode,
  }) {
    return PhotographerProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  PhotographerProfileState clearError() {
    return copyWith(errorMessage: null);
  }
}

/// 사진작가 프로필 Notifier
class PhotographerProfileNotifier extends Notifier<PhotographerProfileState> {
  late PhotographerProfileRepository _repository;

  // Repository Getter (참고 코드 패턴 따름)
  PhotographerProfileRepository get repository => _repository;

  @override
  PhotographerProfileState build() {
    final dio = ref.watch(dioProvider); // DioProvider 사용하는지 확인
    _repository = PhotographerProfileRepositoryImpl(dio);
    return const PhotographerProfileState();
  }

  /// 내 프로필 조회
  Future<void> loadMyProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final profile = await _repository.getMyProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        isEditMode: profile != null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 프로필 저장 (생성/수정)
  Future<bool> saveProfile({
    required String businessName,
    String? introduction,
    required String location,
    int? experienceYears,
    required String displayStatus,
    String? profileImageUrl,
  }) async {
    // 유효성 검사
    final validationError = _validateFormData(
      businessName: businessName,
      location: location,
      experienceYears: experienceYears,
    );

    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // DTO 생성
      final dto = _createDtoFromFormData(
        businessName: businessName,
        introduction: introduction,
        location: location,
        experienceYears: experienceYears,
        displayStatus: displayStatus,
        profileImageUrl: profileImageUrl,
      );

      // 생성 또는 수정
      final PhotographerProfile savedProfile;
      if (state.isEditMode && state.profile != null) {
        savedProfile = await _repository.updateProfile(state.profile!.id, dto);
      } else {
        savedProfile = await _repository.createProfile(dto);
      }

      state = state.copyWith(
        profile: savedProfile,
        isLoading: false,
        isEditMode: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 프로필 상태 변경
  Future<bool> updateProfileStatus(String status) async {
    if (state.profile == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateProfileStatus(state.profile!.id, status);

      final updatedProfile = state.profile!.copyWith(status: status);
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 프로필 삭제
  Future<bool> deleteProfile() async {
    if (state.profile == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteProfile(state.profile!.id);

      state = state.copyWith(
        profile: null,
        isLoading: false,
        isEditMode: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.clearError();
  }

  /// 편집 모드 설정
  void setEditMode(bool isEdit) {
    state = state.copyWith(isEditMode: isEdit);
  }

  /// 폼 데이터 유효성 검사
  String? _validateFormData({
    required String businessName,
    required String location,
    int? experienceYears,
  }) {
    if (businessName.trim().isEmpty) {
      return '상호명을 입력해주세요';
    }

    if (location.trim().isEmpty) {
      return '활동 지역을 입력해주세요';
    }

    if (experienceYears != null &&
        (experienceYears < 0 || experienceYears > 50)) {
      return '경력 연수는 0-50 사이의 값을 입력해주세요';
    }

    return null;
  }

  /// 폼 데이터에서 DTO 생성
  PhotographerProfileFormDto _createDtoFromFormData({
    required String businessName,
    String? introduction,
    required String location,
    int? experienceYears,
    required String displayStatus,
    String? profileImageUrl,
  }) {
    return PhotographerProfileFormDto(
      id: state.profile?.id ?? '',
      businessName: businessName.trim(),
      introduction:
          introduction?.trim().isNotEmpty == true ? introduction!.trim() : null,
      location: location.trim(),
      experienceYears: experienceYears,
      status: _convertToApiStatus(displayStatus),
      profileImageUrl: profileImageUrl,
    );
  }

  /// 화면 상태 → API 상태 변환
  String _convertToApiStatus(String displayStatus) {
    switch (displayStatus) {
      case '활성':
        return 'active';
      case '비활성':
        return 'inactive';
      default:
        return 'active';
    }
  }
}

/// Provider 정의 (참고 코드 패턴 따름)
final photographerProfileProvider =
    NotifierProvider<PhotographerProfileNotifier, PhotographerProfileState>(
  () => PhotographerProfileNotifier(),
);

/// 편의용 Provider들
final isProfileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(photographerProfileProvider).isLoading;
});

final profileErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(photographerProfileProvider).errorMessage;
});

final hasProfileProvider = Provider<bool>((ref) {
  return ref.watch(photographerProfileProvider).profile != null;
});

final currentProfileProvider = Provider<PhotographerProfile?>((ref) {
  return ref.watch(photographerProfileProvider).profile;
});
