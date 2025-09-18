import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dtos/auth_dto.dart';
import '../data/models/repositories/auth_repository.dart';
import 'auth/session_provider.dart';

class AuthState {
  final LoginResponse? login;
  final SocialLoginResponse? social;
  final bool isProgress;

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

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login(LoginRequest request) async {
    print("[AuthProvider] login() 시작. isProgress=true");
    state = state.copyWith(isProgress: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final session = ref.read(sessionProvider.notifier);

      print("[AuthProvider] Repository의 login() 호출 시도...");
      final loginResponse = await repo.login(request);
      print("[AuthProvider] Repository로부터 응답 성공!");

      print("--- [!!!] 서버 로그인 응답 확인 [!!!] ---");
      print("userId: ${loginResponse.userId}");
      print("nickname: ${loginResponse.nickname}");
      print("userTypeCode: ${loginResponse.userTypeCode}");
      print("-------------------------------------");

      print("[AuthProvider] 세션 저장 시도...");
      await session.login(
        loginResponse.accessToken,
        loginResponse.userId,
        loginResponse.nickname,
        loginResponse.userTypeCode,
      );
      print("[AuthProvider] 세션 저장 성공. 로그인 상태 업데이트 시도.");

      state = state.copyWith(login: loginResponse, isProgress: false);
      print("[AuthProvider] 로그인 성공 상태로 업데이트 완료. isProgress=false");

    } catch (e) {
      print("[AuthProvider] !!!!! 로그인 에러 발생 !!!!!: $e");
      state = state.copyWith(isProgress: false);
      rethrow;
    }
  }

  Future<void> kakaoLogin(SocialLoginRequest request) async {
    print("[AuthProvider] kakaoLogin() 시작. isProgress=true");
    state = state.copyWith(isProgress: true);

    try {
      final repo = ref.read(authRepositoryProvider);
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

  void logout() {
    ref.read(sessionProvider.notifier).logout();
    state = const AuthState();
    print("[AuthProvider] 로그아웃 완료. 세션 및 로컬 상태 초기화.");
  }

  // 회원 탈퇴 메서드 추가
  Future<void> withdraw() async {
    final session = ref.read(sessionProvider);
    if (session.userId == null) {
      throw Exception('로그인 상태가 아니거나 사용자 ID를 찾을 수 없습니다.');
    }

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.deleteUser(session.userId!);

      // 탈퇴 성공 시, 세션 정보를 완전히 삭제 (로그아웃과 동일한 효과)
      logout();
      print("[AuthProvider] 회원 탈퇴 성공. 모든 세션 및 로컬 상태를 초기화합니다.");
    } catch (e) {
      print("[AuthProvider] !!!!! 회원 탈퇴 에러 발생 !!!!!: $e");
      rethrow; // UI로 에러를 다시 던져서 피드백을 줍니다.
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
