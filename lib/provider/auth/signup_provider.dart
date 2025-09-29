import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dtos/auth_dto.dart';
import '../../data/models/_repositories/signup_auth_repository.dart';
import '../core/dio_provider.dart';

final signupAuthRepositoryProvider = Provider<SignupAuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SignupAuthRepository(dio);
});

// 2회원가입 진행 상태 enum
enum SignupStatus {
  initial,
  loading,
  success,
  error,
}

// 회원가입 상태를 나타내는 클래스
class SignupState {
  final SignupStatus status;
  final RegisterResponse? responseData;
  final String? errorMessage;

  const SignupState({
    this.status = SignupStatus.initial,
    this.responseData,
    this.errorMessage,
  });

  SignupState copyWith({
    SignupStatus? status,
    RegisterResponse? responseData,
    String? errorMessage,
    bool clearResponseData = false,
    bool clearErrorMessage = false,
  }) {
    return SignupState(
      status: status ?? this.status,
      responseData:
          clearResponseData ? null : responseData ?? this.responseData,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SignupNotifier extends Notifier<SignupState> {
  @override
  SignupState build() {
    return const SignupState();
  }

  // 회원가입 요청 메서드
  Future<void> registerUser(RegisterRequest request) async {
    final signupAuthRepository = ref.read(signupAuthRepositoryProvider);

    state = state.copyWith(
        status: SignupStatus.loading,
        clearErrorMessage: true,
        clearResponseData: true);
    try {
      final response = await signupAuthRepository.register(request);
      state =
          state.copyWith(status: SignupStatus.success, responseData: response);
    } catch (e) {
      state = state.copyWith(
          status: SignupStatus.error, errorMessage: e.toString());
    }
  }

  // 상태를 초기화하는 메서드
  void resetState() {
    state = const SignupState();
  }
}

final signupProvider =
    NotifierProvider<SignupNotifier, SignupState>(() => SignupNotifier());
