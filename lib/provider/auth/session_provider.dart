import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../photographer_profile/photographer_profile_notifier.dart';
import '../user_profile/user_profile_provider.dart';

class AppSession {
  final String? jwtToken;
  final int? userId;
  final String? userNickname;
  final String? userTypeCode;
  final bool isLogin;

  AppSession({
    this.jwtToken,
    this.userId,
    this.userNickname,
    this.userTypeCode,
    this.isLogin = false,
  });

  AppSession copyWith({
    String? jwtToken,
    int? userId,
    String? userNickname,
    String? userTypeCode,
    bool? isLogin,
  }) {
    return AppSession(
      jwtToken: jwtToken ?? this.jwtToken,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
      userTypeCode: userTypeCode ?? this.userTypeCode,
      isLogin: isLogin ?? this.isLogin,
    );
  }
}

// 세션 상태를 관리하는 StateNotifier
class SessionNotifier extends StateNotifier<AppSession> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _jwtTokenKey = 'auth_jwt_token';
  final String _userIdKey = 'auth_user_id';
  final String _userNicknameKey = 'auth_user_nickname';
  final String _userTypeCodeKey = 'auth_user_type_code';

  final Ref _ref;

  SessionNotifier(this._ref) : super(AppSession()) {}

  Future<void> loadSessionFromStorage() async {
    try {
      final token = await _secureStorage.read(key: _jwtTokenKey);
      final userIdString = await _secureStorage.read(key: _userIdKey);
      final nickname = await _secureStorage.read(key: _userNicknameKey);
      final userTypeCode = await _secureStorage.read(key: _userTypeCodeKey);

      if (token != null && userIdString != null && userTypeCode != null) {
        state = AppSession(
          jwtToken: token,
          userId: int.tryParse(userIdString),
          userNickname: nickname,
          userTypeCode: userTypeCode,
          isLogin: true,
        );

        try {
          final userType = userTypeCode.toUpperCase();
          if (userType == 'PHOTOGRAPHER') {
            _ref.invalidate(photographerProfileProvider);
            _ref.read(photographerProfileProvider.notifier).loadMyProfile();
          } else {
            _ref.invalidate(userProfileProvider);
            _ref.read(userProfileProvider.notifier).loadMyProfile();
          }
        } catch (_) {}
      } else {
        state = AppSession(isLogin: false);
      }
    } catch (e) {
      print("세션 정보 로드 실패: $e");
      state = AppSession(isLogin: false);
    }
  }

  // 로그인 성공 시 호출될 메서드
  Future<void> login(
      String token, int userId, String nickname, String userTypeCode) async {
    try {
      await _secureStorage.write(key: _jwtTokenKey, value: token);
      await _secureStorage.write(key: _userIdKey, value: userId.toString());
      await _secureStorage.write(key: _userNicknameKey, value: nickname);
      await _secureStorage.write(key: _userTypeCodeKey, value: userTypeCode);
      state = AppSession(
          jwtToken: token,
          userId: userId,
          userNickname: nickname,
          userTypeCode: userTypeCode,
          isLogin: true);

      try {
        _ref.invalidate(userProfileProvider);
      } catch (_) {}
      try {
        _ref.invalidate(photographerProfileProvider);
      } catch (_) {}

      try {
        final userType = userTypeCode.toUpperCase();
        if (userType == 'PHOTOGRAPHER') {
          _ref.read(photographerProfileProvider.notifier).loadMyProfile();
        } else {
          _ref.read(userProfileProvider.notifier).loadMyProfile();
        }
      } catch (_) {}
    } catch (e) {
      print("세션 정보 저장 실패 (로그인): $e");
    }
  }

  Future<void> logout() async {
    try {
      await _secureStorage.deleteAll(); // 모든 관련 정보 삭제
      state = AppSession(isLogin: false);

      // 로그아웃 시 관련 상태 초기화
      try {
        _ref.invalidate(userProfileProvider);
      } catch (_) {}
      try {
        _ref.invalidate(photographerProfileProvider);
      } catch (_) {}
    } catch (e) {
      print("세션 정보 삭제 실패 (로그아웃): $e");
    }
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, AppSession>((ref) {
  return SessionNotifier(ref);
});
