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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(sessionProvider);
      // 디버그 출력 추가
      print('[DEBUG] 세션 정보:');
      print('[DEBUG] isLogin: ${session.isLogin}');
      print('[DEBUG] userTypeCode: ${session.userTypeCode}');

      if (session.isLogin) {
        if (session.userTypeCode == 'photographer') {
          print('[DEBUG] 포토그래퍼로 인식됨');
          ref.read(photographerProfileProvider.notifier).loadMyProfile();
        } else {
          print('[DEBUG] 일반 사용자로 인식됨');
          ref.read(userProfileProvider.notifier).loadMyProfile();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          if (session.isLogin) {
            // 사용자 타입에 따른 조건부 새로고침
            if (session.userTypeCode == 'photographer') {
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
