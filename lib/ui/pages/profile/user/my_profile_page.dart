import 'package:chakak_flutter/ui/pages/profile/user/widgets/profile_menu_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/app_sizes.dart';
import '../../../../provider/auth/session_provider.dart';
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
    // 프로필 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(sessionProvider);
      if (session.isLogin) {
        ref.read(userProfileProvider.notifier).loadMyProfile();
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
            return ref.read(userProfileProvider.notifier).refresh();
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
