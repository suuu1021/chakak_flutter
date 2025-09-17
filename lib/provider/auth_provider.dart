import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dtos/auth_dto.dart';
import '../data/models/repositories/auth_repository.dart';
import 'auth/session_provider.dart';

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
      // ==================== 시연용 더미 로그인 (영상 촬영 후 삭제) ====================
      // 더미 계정 체크
      if (request.email == "test@test.com" && request.password == "123456") {
        print("[AuthProvider] 더미 계정으로 로그인 시도");
        await Future.delayed(const Duration(milliseconds: 800)); // 로딩 시뮬레이션

        // 더미 응답 생성
        final dummyLoginResponse = LoginResponse(
          tokenType: "Bearer",
          accessToken: "dummy_access_token_12345",
          userId: 1,
          email: "test@test.com",
          nickname: "테스트 유저",
          userTypeCode: "USER", // 일반 사용자
        );

        print("[AuthProvider] 더미 세션 저장 시도...");
        final session = ref.read(sessionProvider.notifier);
        await session.login(
          dummyLoginResponse.accessToken,
          dummyLoginResponse.userId,
          dummyLoginResponse.nickname,
          dummyLoginResponse.userTypeCode,
        );
        print("[AuthProvider] 더미 세션 저장 성공!");

        state = state.copyWith(login: dummyLoginResponse, isProgress: false);
        print("[AuthProvider] 더미 로그인 성공 완료!");
        return;
      }
      // ==================== 시연용 더미 로그인 끝 ====================

      // ==================== 기존 실제 로그인 로직 (주석 보관) ====================
      /*
      final repo = ref.read(authRepositoryProvider);
      final session = ref.read(sessionProvider.notifier);

      print("[AuthProvider] Repository의 login() 호출 시도...");
      final loginResponse = await repo.login(request);
      print("[AuthProvider] Repository로부터 응답 성공!");

      print("[AuthProvider] 세션 저장 시도...");
      await session.login(
        loginResponse.accessToken,
        loginResponse.userId,
        loginResponse.nickname,
        loginResponse.userTypeCode, // 'userType' -> 'userTypeCode' 로 수정
      );
      print("[AuthProvider] 세션 저장 성공. 로그인 상태 업데이트 시도.");

      state = state.copyWith(login: loginResponse, isProgress: false);
      print("[AuthProvider] 로그인 성공 상태로 업데이트 완료. isProgress=false");
      */
      // ==================== 기존 실제 로그인 로직 끝 ====================

      // 더미 계정이 아닌 경우 에러 발생
      await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
      throw Exception("잘못된 이메일 또는 비밀번호입니다");
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
final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
