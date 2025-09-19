import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dtos/user_profile_dto.dart';
import '../../../data/models/user_profile.dart';
import '../../../service/user_profile_service.dart';
import '../../auth/session_provider.dart';
import '../../core/dio_provider.dart';

// State 클래스
class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;
  final bool isCreating;
  final bool isUpdating;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.isCreating = false,
    this.isUpdating = false,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
    bool? isCreating,
    bool? isUpdating,
    bool clearErrorMessage = false,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

// Notifier 클래스
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserProfileService _userProfileService;
  final Ref _ref;

  UserProfileNotifier(this._userProfileService, this._ref)
      : super(const UserProfileState());

  // 내 프로필 조회
  Future<void> loadMyProfile() async {
    try {
      final session = _ref.read(sessionProvider);
      print('[DEBUG] UserProfileNotifier.loadMyProfile 호출 - isLogin: ${session.isLogin}, userTypeCode: ${session.userTypeCode}');
      print('[DEBUG] StackTrace: ${StackTrace.current}');
    } catch (_) {}
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);
      final profileDto = await _userProfileService.getMyProfile();
      final profile = profileDto.toModel();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '프로필을 불러오는데 실패했습니다.');
    }
  }

  // 프로필 생성
  Future<bool> createProfile(UserProfileCreateRequestDto request) async {
    try {
      state = state.copyWith(isCreating: true, clearErrorMessage: true);
      final profileDto = await _userProfileService.createProfile(request);
      final profile = profileDto.toModel();
      state = state.copyWith(profile: profile, isCreating: false);
      return true;
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: '프로필 생성에 실패했습니다.');
      return false;
    }
  }

  // 프로필 수정 (최신 API 명세 반영)
  Future<bool> updateProfile(UserProfileUpdateRequestDto request) async {
    try {
      state = state.copyWith(isUpdating: true, clearErrorMessage: true);
      // 1. 서비스에서 수정된 프로필 DTO를 직접 받음
      final updatedProfileDto = await _userProfileService.updateProfile(request);
      // 2. DTO를 UI 모델로 변환
      final updatedProfile = updatedProfileDto.toModel();
      // 3. 변환된 모델로 상태를 즉시 업데이트 (불필요한 API 재호출 제거)
      state = state.copyWith(profile: updatedProfile, isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, errorMessage: '프로필 수정에 실패했습니다: ${e.toString()}');
      return false;
    }
  }

  // 닉네임 중복 체크
  Future<bool> checkNicknameDuplicate(String nickname) async {
    try {
      return await _userProfileService.checkNicknameDuplicate(nickname);
    } catch (e) {
      return false;
    }
  }

  // 새로고침
  Future<void> refresh() async {
    await loadMyProfile();
  }

  // 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  // 프로필 상태 초기화
  void clearProfile() {
    state = const UserProfileState();
  }
}

// Provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final dio = ref.watch(dioProvider);
  final userProfileService = UserProfileService(dio);
  return UserProfileNotifier(userProfileService, ref);
});
