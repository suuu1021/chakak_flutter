import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository와 DTO, dioProvider import는 이전과 동일하게 필요합니다.
import '../../data/models/repositories/signup_auth_repository.dart';
import '../../data/dtos/auth_dto.dart'; // RegisterRequest, RegisterResponse DTO
import '../core/dio_provider.dart'; // dioProvider

// 1. SignupAuthRepository를 위한 Provider (변경 없음)
final signupAuthRepositoryProvider = Provider<SignupAuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SignupAuthRepository(dio);
});

// 2. 회원가입 진행 상태 enum (변경 없음)
enum SignupStatus {
  initial,
  loading,
  success,
  error,
}

// 3. 회원가입 상태를 나타내는 클래스 (변경 없음)
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
  // Notifier는 생성자에서 의존성을 주입받지 않고,

  @override
  SignupState build() {
    // build 메서드에서 초기 상태를 반환합니다.
    return const SignupState();
  }

  // 회원가입 요청 메서드
  Future<void> registerUser(RegisterRequest request) async {
    // Notifier 내에서는 ref를 직접 사용할 수 있습니다.
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
    state = const SignupState(); // 초기 상태로 되돌림
  }
}

final signupProvider =
    NotifierProvider<SignupNotifier, SignupState>(() => SignupNotifier());
