import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../global/user_profile/user_profile_provider.dart';
import '../global/photographer_profile/photographer_profile_notifier.dart';

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

  final Ref _ref; // Provider ref를 보관하여 다른 프로바이더 접근

  SessionNotifier(this._ref) : super(AppSession()) {
    // 앱이 시작될 때 저장소에서 세션 정보를 로드합니다.
    // loadSessionFromStorage();
  }

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

        // 세션이 로드되면 해당 유저 타입에 맞는 프로필을 로드
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
        // 저장된 정보가 없으면 로그아웃 상태
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

      // 로그인 후, 다른 프로바이더의 상태를 초기화/갱신
      try {
        _ref.invalidate(userProfileProvider);
      } catch (_) {}
      try {
        _ref.invalidate(photographerProfileProvider);
      } catch (_) {}

      // 로그인 직후에 해당 타입의 프로필을 즉시 로드
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

  // 로그아웃 시 호출될 메서드
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

// 앱 전역에서 SessionNotifier를 사용할 수 있도록 하는 프로바이더
final sessionProvider =
    StateNotifierProvider<SessionNotifier, AppSession>((ref) {
  return SessionNotifier(ref);
});
