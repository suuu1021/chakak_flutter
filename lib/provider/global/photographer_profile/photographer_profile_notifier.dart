import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dtos/photographer_profile_dto.dart';
import '../../../data/models/photographer_profile.dart';
import '../../../data/models/repositories/photographer_profile_repository.dart';
import '../../auth/session_provider.dart';
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
    bool setProfileToNull = false, 
  }) {
    return PhotographerProfileState(
      profile: setProfileToNull ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  // PhotographerProfileState의 clearError는 Notifier에서 직접 copyWith를 사용하므로,
  // 여기서는 중복 정의를 피하거나, 만약 State 자체에서도 필요하다면 유지합니다.
  // 현재 Notifier는 State의 이 메소드를 사용하지 않습니다.
  // PhotographerProfileState clearError() {
  //   return copyWith(errorMessage: null);
  // }
}

/// 사진작가 프로필 Notifier
class PhotographerProfileNotifier extends Notifier<PhotographerProfileState> {
  late PhotographerProfileRepository _repository;

  PhotographerProfileRepository get repository => _repository;

  @override
  PhotographerProfileState build() {
    final dio = ref.watch(dioProvider); 
    _repository = PhotographerProfileRepositoryImpl(dio);
    return const PhotographerProfileState();
  }

  Future<void> loadMyProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _repository.getMyProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        isEditMode: profile != null,
        setProfileToNull: profile == null, 
      );
    } catch (e) {
      try {
        final err = e.toString();
        if (err.contains('인증 정보가 누락') || err.contains('인증이 만료')) {
          try {
            ref.read(sessionProvider.notifier).logout();
          } catch (_) {}
          state = state.copyWith(isLoading: false, errorMessage: '인증 정보가 유효하지 않습니다. 다시 로그인해주세요.', setProfileToNull: true);
          return;
        }
      } catch (_) {}
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        setProfileToNull: true, 
      );
    }
  }

  Future<bool> saveProfile({
    required String businessName,
    String? introduction,
    required String location,
    int? experienceYears,
    String? profileImageUrl,
    List<int>? categoryIds,
  }) async {
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
      final dto = _createDtoFromFormData(
        businessName: businessName,
        introduction: introduction,
        location: location,
        experienceYears: experienceYears,
        profileImageUrl: profileImageUrl,
        categoryIds: categoryIds,
      );

      if (state.isEditMode && state.profile != null) {
        await _repository.updateProfile(state.profile!.id, dto);
        await loadMyProfile(); 
        
        if (state.errorMessage == null) { 
          state = state.copyWith(isEditMode: true, isLoading: false); 
          return true;
        } else {
          return false;
        }
      } else {
        final PhotographerProfile createdProfile = await _repository.createProfile(dto);
        state = state.copyWith(
          profile: createdProfile,
          isLoading: false,
          isEditMode: true,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteProfile() async {
    if (state.profile == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteProfile(state.profile!.id);
      state = state.copyWith(
        profile: null,
        isLoading: false,
        isEditMode: false,
        setProfileToNull: true, 
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearError() {
    if (state.errorMessage != null) { 
      state = state.copyWith(errorMessage: null);
    }
  }

  void setEditMode(bool isEdit) {
    state = state.copyWith(isEditMode: isEdit);
  }
  
  void clearProfile() { 
    state = const PhotographerProfileState();
  }

  String? _validateFormData({
    required String businessName,
    required String location,
    int? experienceYears,
  }) {
    if (businessName.trim().isEmpty) return '상호명을 입력해주세요';
    if (location.trim().isEmpty) return '활동 지역을 입력해주세요';
    if (experienceYears != null && (experienceYears < 0 || experienceYears > 50)) {
      return '경력 연수는 0-50 사이의 값을 입력해주세요';
    }
    return null;
  }

  PhotographerProfileFormDto _createDtoFromFormData({
    required String businessName,
    String? introduction,
    required String location,
    int? experienceYears,
    String? profileImageUrl,
    List<int>? categoryIds,
  }) {
    return PhotographerProfileFormDto(
      businessName: businessName.trim(),
      introduction: introduction?.trim().isNotEmpty == true ? introduction!.trim() : null,
      location: location.trim(),
      experienceYears: experienceYears,
      profileImageUrl: profileImageUrl,
      categoryIds: categoryIds,
    );
  }
}

final photographerProfileProvider =
    NotifierProvider<PhotographerProfileNotifier, PhotographerProfileState>(
  () => PhotographerProfileNotifier(),
);

final isProfileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(photographerProfileProvider.select((s) => s.isLoading));
});

final profileErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(photographerProfileProvider.select((s) => s.errorMessage));
});

final hasProfileProvider = Provider<bool>((ref) {
  return ref.watch(photographerProfileProvider.select((s) => s.profile != null));
});

final currentProfileProvider = Provider<PhotographerProfile?>((ref) {
  return ref.watch(photographerProfileProvider.select((s) => s.profile));
});
