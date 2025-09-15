import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dtos/auth_dto.dart';
import '../data/models/repositories/auth_repository.dart';

class AuthState {
  final LoginResponse? login; // 일반 로그인 결과
  final SocialLoginResponse? social; // 소셜 로그인 결과

  const AuthState({this.login, this.social});

  AuthState copyWith({
    LoginResponse? login,
    SocialLoginResponse? social,
  }) {
    return AuthState(
      login: login ?? this.login,
      social: social ?? this.social,
    );
  }
} // end of AuthState

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repo;

  // 외부에서 필요하면 Repository 접근 가능
  AuthRepository get repository => _repo;

  @override
  AuthState build() {
    _repo = AuthRepository(baseUrl: 'http://10.0.2.2:8080'); // TODO: .env 처리 가능
    return const AuthState();
  }

  /// 일반 로그인
  Future<void> login(LoginRequest request) async {
    final res = await _repo.login(request);
    state = state.copyWith(login: res);
  }

  /// 카카오 로그인
  Future<void> kakaoLogin(SocialLoginRequest request) async {
    final res = await _repo.kakaoLogin(request);
    state = state.copyWith(social: res);
  }

  /// 로그아웃
  void logout() {
    state = const AuthState();
  }
} // end of AuthNotifier//

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);
