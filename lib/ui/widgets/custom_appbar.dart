// Custom AppBar
import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:chakak_flutter/provider/auth/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_core/constants/app_routes.dart';
import '../../_core/constants/app_strings.dart';
import '../pages/profile/user/widgets/login_required_dialog.dart';
import 'custom_bottom_navigation_bar.dart';

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  final AppSession session;
  const CustomAppbar({
    super.key,
    required this.session,
  });

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

  // 로그인 확인 후 액션 실행하는 메서드
  void _handleLoginRequiredAction(VoidCallback action) {
    if (!widget.session.isLogin) {
      LoginRequiredDialog.show(context);
      return;
    }
    action();
  }

  // 로그인 확인 후 네비게이션하는 메서드
  void _handleLoginRequiredNavigation(String route) {
    if (!widget.session.isLogin) {
      LoginRequiredDialog.show(context);
      return;
    }
    _navigateToRoute(route);
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
                icon: const Icon(Icons.calendar_month),
                onPressed: _isNavigating
                    ? null
                    : () {
                        //_navigateToRoute(AppRoutes.userBookingList);
                        _handleLoginRequiredNavigation(
                            AppRoutes.userBookingList);
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
