import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../_core/constants/app_routes.dart';
import '../../../data/models/user_profile.dart';
import '../../../provider/auth/session_provider.dart';
import '../../../provider/global/photographer_profile/photographer_profile_notifier.dart';
import '../../../provider/global/user_profile/user_profile_provider.dart';
import 'photographer/photographer_profile_form_page.dart';
import 'user/profile_form_page.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  bool _navigatedToLogin = false;
  bool _requestedPhotographerLoad = false; // 추가

  @override
  void initState() {
    super.initState();
  }

  void _navigateToLogin(BuildContext context) {
    if (_navigatedToLogin) return;
    _navigatedToLogin = true;
    // 라우트로 이동
    Navigator.pushNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    // 세션 변경 감지: 로그인 및 유저타입 변경 시 관련 프로바이더 초기화/로딩
    ref.listen<AppSession>(sessionProvider, (previous, next) {
      // 세션이 바뀌면 이전에 남아있을 수 있는 프로필 상태 초기화
      final prevType = previous?.userTypeCode?.toUpperCase();
      final nextType = next.userTypeCode?.toUpperCase();

      // 로그인 상태가 변경되어 로그아웃된 경우 모든 프로필 초기화
      if (!next.isLogin) {
        try {
          ref.read(userProfileProvider.notifier).clearProfile();
        } catch (_) {}
        try {
          ref.read(photographerProfileProvider.notifier).clearProfile();
        } catch (_) {}
        _requestedPhotographerLoad = false;
        return;
      }

      // 로그인 후 유저타입 변경 처리
      if (prevType != nextType) {
        if (nextType == 'PHOTOGRAPHER') {
          // 유저 프로필 초기화 후 포토그래퍼 프로필 로드
          try {
            ref.read(userProfileProvider.notifier).clearProfile();
          } catch (_) {}
          _requestedPhotographerLoad = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_requestedPhotographerLoad) {
              _requestedPhotographerLoad = true;
              ref.read(photographerProfileProvider.notifier).loadMyProfile();
            }
          });
        } else {
          // 포토그래퍼 프로필 초기화 후 일반 유저 프로필 로드
          try {
            ref.read(photographerProfileProvider.notifier).clearProfile();
          } catch (_) {}
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(userProfileProvider.notifier).loadMyProfile();
            }
          });
        }
      }
    });

    // 로그인 체크
    if (!session.isLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('로그인 필요'),
              content: const Text('프로필 수정은 로그인 후에 이용 가능합니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _navigateToLogin(context);
                  },
                  child: const Text('로그인'),
                ),
              ],
            ),
          );
        }
      });

      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // userTypeCode 비교: 서버에서 소문자가 올 수 있으므로 대문자로 변환
    final userTypeCode = session.userTypeCode?.toUpperCase();

    // userTypeCode가 아직 로드되지 않은 경우 로딩 상태를 보여주고 아무런 프로필 호출을 하지 않음
    if (session.userTypeCode == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('프로필 수정')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 디버그: 세션과 userTypeCode 출력
    print(
        '[DEBUG] ProfileEditPage - isLogin: ${session.isLogin}, userTypeCode: ${session.userTypeCode} -> $userTypeCode');

    if (userTypeCode == 'PHOTOGRAPHER') {
      // 기존 일반 유저 프로필 초기화 (이전 로그인 세션의 데이터 제거)
      try {
        ref.read(userProfileProvider.notifier).clearProfile();
      } catch (_) {}
      // 포토그래퍼 프로필을 한 번만 로드
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_requestedPhotographerLoad) {
          _requestedPhotographerLoad = true;
          print('[DEBUG] ProfileEditPage - 요청: 포토그래퍼 프로필 로드 실행');
          ref.read(photographerProfileProvider.notifier).loadMyProfile();
        }
      });
      return PhotographerProfileFormPage();
    }

    // 기본은 일반 유저 폼
    final userProfileState = ref.watch(userProfileProvider);

    // 프로필이 없고 로딩중이 아닐 때 로드 요청
    if (userProfileState.profile == null && !userProfileState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProfileProvider.notifier).loadMyProfile();
      });
    }

    if (userProfileState.isLoading || userProfileState.profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('프로필 수정')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final UserProfile profile = userProfileState.profile!;

    return ProfileFormPage(userProfile: profile);
  }
}
