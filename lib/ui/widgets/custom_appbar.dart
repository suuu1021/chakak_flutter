// Custom AppBar
import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_core/constants/app_routes.dart';
import '../../_core/constants/app_strings.dart';
import 'custom_bottom_navigation_bar.dart';

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppbarState extends State<CustomAppbar> {
  bool _isNavigating = false;

  void _navigateToRoute(String route) {
    if (_isNavigating || !mounted) return;

    // Navigator가 현재 안전한 상태인지 확인
    final navigator = Navigator.of(context, rootNavigator: false);
    final modalRoute = ModalRoute.of(context);

    if (modalRoute == null || !modalRoute.isCurrent) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    // 현재 프레임이 완전히 끝난 후에 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Future.delayed(const Duration(milliseconds: 100), () async {
        if (!mounted || _isNavigating == false) return;

        try {
          await navigator.pushNamed(route);
        } catch (e) {
          print('Navigation error: $e');
        } finally {
          if (mounted) {
            setState(() {
              _isNavigating = false;
            });
          }
        }
      });
    });
  }

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
                onPressed: _isNavigating
                    ? null
                    : () {
                        ProviderScope.containerOf(context)
                            .read(bottomNavIndexProvider.notifier)
                            .state = 1;
                      },
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _isNavigating
                    ? null
                    : () {
                        _navigateToRoute(AppRoutes.notification);
                      },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _isNavigating
                    ? null
                    : () {
                        _navigateToRoute(AppRoutes.userBookingList);
                      },
              ),
              IconButton(
                icon: const Icon(Icons.reviews), //  리뷰 아이콘
                onPressed: _isNavigating
                    ? null
                    : () {
                        //  일반 사용자라면 내가 작성한 리뷰로
                        _navigateToRoute(AppRoutes.myReviews);
                        //  포토그래퍼 계정이면 아래 코드로 교체
                        // _navigateToRoute('/photographer-reviews');
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
