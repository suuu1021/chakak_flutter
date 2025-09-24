import 'package:chakak_flutter/ui/pages/profile/user/widgets/profile_menu_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/app_sizes.dart';
import '../../../../provider/auth/session_provider.dart';
import '../../../../provider/global/photographer_profile/photographer_profile_notifier.dart';
import '../../../../provider/global/user_profile/user_profile_provider.dart';
import 'widgets/profile_header.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // 마이페이지 진입 시 바로 프로필 로드
    // 포토그래퍼인 경우, photographerProfileProvider를 사용
    final session = ref.read(sessionProvider);
    if (session.isLogin) {
      final userType = session.userTypeCode?.toUpperCase();
      if (userType == 'PHOTOGRAPHER') {
        print('[DEBUG] 포토그래퍼로 인식됨, 내 프로필 로드');
        ref.read(photographerProfileProvider.notifier).loadMyProfile();
      } else {
        print('[DEBUG] 일반 사용자로 인식됨, 내 프로필 로드');
        ref.read(userProfileProvider.notifier).loadMyProfile();
      }
    }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          if (session.isLogin) {
            final userType = session.userTypeCode?.toUpperCase();
            if (userType == null) {
              return Future.value();
            } else if (userType == 'PHOTOGRAPHER') {
              // 새로고침 시에도 동일한 프로바이더 사용
              return ref
                  .read(photographerProfileProvider.notifier)
                  .loadMyProfile();
            } else {
              return ref.read(userProfileProvider.notifier).refresh();
            }
          } else {
            return Future.value();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            children: [
              ProfileHeader(session: session),
              const SizedBox(height: AppSizes.spacing24),
              ProfileMenuList(session: session),
            ],
          ),
        ),
      ),
    );
  }
}
