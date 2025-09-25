import 'package:chakak_flutter/provider/auth/session_provider.dart';
import 'package:chakak_flutter/ui/pages/profile/user/widgets/login_required_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_core/constants/app_colors.dart';
import '../../_core/constants/app_strings.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({super.key});

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: AppStrings.home,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: AppStrings.search,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.domain_rounded),
      label: AppStrings.community,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline_rounded),
      label: AppStrings.chat,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: AppStrings.profile,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final session = ref.watch(sessionProvider); // 세션 가져오기

    return BottomNavigationBar(
      items: _navItems,
      currentIndex: currentIndex,
      onTap: (index) {
        print("index 값 확인 : $index");
        if(index == 2 || index == 3) {
          if (!session.isLogin) {
            // 로그인되지 않은 경우 다이얼로그 표시
            LoginRequiredDialog.show(context);
            return;
          }
          // 로그인된 경우 채팅 탭으로 이동
          ref.read(bottomNavIndexProvider.notifier).state = index;
        }else {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey[500],
      backgroundColor: AppColors.primaryLight,
      showSelectedLabels: true,
      showUnselectedLabels: false,
    );
  }
}
