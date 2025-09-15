// Custom AppBar
import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_core/constants/app_routes.dart';
import '../../_core/constants/app_strings.dart';
import 'custom_bottom_navigation_bar.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.grey[800],
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.appNameUpper,
            style: TextStyle(
                fontSize: 28,
                fontFamily: AppStrings.fontFamily1,
                color: AppColors.primary),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  ProviderScope.containerOf(context)
                      .read(bottomNavIndexProvider.notifier)
                      .state = 1;
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.notification);
                },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.userBookingList);
                },
              ),
              IconButton(
                icon: const Icon(Icons.reviews), //  리뷰 아이콘
                onPressed: () {
                  //  일반 사용자라면 내가 작성한 리뷰로
                  Navigator.of(context).pushNamed(AppRoutes.myReviews);
                  //  포토그래퍼 계정이면 아래 코드로 교체
                  // Navigator.pushNamed(context, '/photographer-reviews');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
