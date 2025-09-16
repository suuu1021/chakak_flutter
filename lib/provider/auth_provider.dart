import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../data/dtos/auth_dto.dart';
import '../data/models/repositories/auth_repository.dart';
import 'auth/session_provider.dart'; // ✅ 경로 수정

// UI 상태를 나타내는 클래스 (일반 + 소셜 로그인 상태 통합)
class AuthState {
  final LoginResponse? login;
  final SocialLoginResponse? social;
  final bool isProgress; // 로그인 진행 상태 표시

  const AuthState({
    this.login,
    this.social,
    this.isProgress = false,
  });

  AuthState copyWith({
    LoginResponse? login,
    SocialLoginResponse? social,
    bool? isProgress,
  }) {
    return AuthState(
      login: login ?? this.login,
      social: social ?? this.social,
      isProgress: isProgress ?? this.isProgress,
    );
  }
}

// 비즈니스 로직을 처리하는 Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  /// [일반 로그인]
  Future<void> login(LoginRequest request) async {
    print("[AuthProvider] login() 시작. isProgress=true");
    state = state.copyWith(isProgress: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final session = ref.read(sessionProvider.notifier);

      print("[AuthProvider] Repository의 login() 호출 시도...");
      final loginResponse = await repo.login(request);
      print("[AuthProvider] Repository로부터 응답 성공!");

      // ✅ [수정] SessionProvider의 명세에 맞게 올바른 메소드와 인자로 호출합니다.
      print("[AuthProvider] 세션 저장 시도...");
      await session.login(
        loginResponse.accessToken,
        loginResponse.userId,
        loginResponse.nickname,
        loginResponse.userType,
      );
      print("[AuthProvider] 세션 저장 성공. 로그인 상태 업데이트 시도.");

      state = state.copyWith(login: loginResponse, isProgress: false);
      print("[AuthProvider] 로그인 성공 상태로 업데이트 완료. isProgress=false");

    } catch (e) {
      print("[AuthProvider] !!!!! 로그인 에러 발생 !!!!!: $e");
      state = state.copyWith(isProgress: false);
      rethrow; // 에러를 UI로 다시 던져서 스낵바 등을 표시
    }
  }

  /// [카카오 로그인]
  Future<void> kakaoLogin(SocialLoginRequest request) async {
    print("[AuthProvider] kakaoLogin() 시작. isProgress=true");
    state = state.copyWith(isProgress: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      // 소셜 로그인은 세션 처리가 다를 수 있으므로 일단 API 호출에 집중
      print("[AuthProvider] Repository의 kakaoLogin() 호출 시도...");
      final socialResponse = await repo.kakaoLogin(request);
      print("[AuthProvider] Repository로부터 응답 성공!");

      state = state.copyWith(social: socialResponse, isProgress: false);
      print("[AuthProvider] 소셜 로그인 성공 상태로 업데이트 완료. isProgress=false");

    } catch (e) {
      print("[AuthProvider] !!!!! 소셜 로그인 에러 발생 !!!!!: $e");
      state = state.copyWith(isProgress: false);
      rethrow;
    }
  }

  /// [로그아웃]
  void logout() {
    ref.read(sessionProvider.notifier).logout();
    state = const AuthState(); // 로컬 상태도 초기화
    print("[AuthProvider] 로그아웃 완료. 세션 및 로컬 상태 초기화.");
  }
}

// Provider 정의
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);