import 'package:chakak_flutter/ui/pages/profile/photographer/photographer_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/user_type.dart';
import '../../../../../provider/auth/session_provider.dart';
import '../../../../../provider/photographer_profile/photographer_profile_notifier.dart';
import '../../../booking/booking_management_screen.dart';
import '../../../help_center/help_center_screen.dart';
import '../../../review/review_manager_screen.dart';
import '../profile_form_page.dart';
import 'login_required_dialog.dart';
import 'logout_dialog.dart';
import 'profile_menu_item.dart';
import 'withdrawal_dialog.dart';

class ProfileMenuList extends ConsumerWidget {
  final AppSession session;

  const ProfileMenuList({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = _buildMenuItems(context, ref);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return ProfileMenuItem(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          onTap: item['onTap'] as VoidCallback,
        );
      },
    );
  }

  List<Map<String, dynamic>> _buildMenuItems(
      BuildContext context, WidgetRef ref) {
    return [
      if (session.isLogin && session.userTypeCode == 'photographer') ...[
        {
          'icon': Icons.edit_note,
          'title': '포토그래퍼 프로필',
          'subtitle': '내 프로필을 확인하세요',
          'onTap': () => _handleProfileEdit(context, ref),
        },
      ],
      {
        'icon': Icons.history,
        'title': '예약 내역',
        'subtitle': '지난 예약 내역을 확인하세요',
        'onTap': () => _handleBookingHistory(context),
      },
      {
        'icon': Icons.star,
        'title': '리뷰 관리',
        'subtitle': '작성/받은 리뷰를 관리하세요',
        'onTap': () => _handleReviewManagement(context, ref),
      },
      {
        'icon': Icons.help,
        'title': '고객센터',
        'subtitle': '문의사항이 있으시면 연락주세요',
        'onTap': () => _handleHelpCenter(context),
      },
      if (session.isLogin) ...[
        {
          'icon': Icons.person_off_outlined,
          'title': '회원 탈퇴',
          'subtitle': '계정을 영구적으로 삭제합니다',
          'onTap': () => WithdrawalDialog.show(context),
        },
        {
          'icon': Icons.logout,
          'title': '로그아웃',
          'subtitle': '계정에서 로그아웃합니다',
          'onTap': () => LogoutDialog.show(context),
        },
      ],
    ];
  }

  Future<void> _handleProfileEdit(BuildContext context, WidgetRef ref) async {
    print('=== 포토그래퍼 프로필 메뉴 선택 ===');
    try {
      await ref.read(photographerProfileProvider.notifier).loadMyProfile();
      final photographerProfile = ref.read(photographerProfileProvider).profile;
      final errorMessage = ref.read(photographerProfileProvider).errorMessage;

      if (errorMessage != null && errorMessage.isNotEmpty) {
        print('[ERROR] 프로필 로드 실패: $errorMessage');
        return;
      }

      if (photographerProfile != null) {
        print('프로필 로드 성공: photographerProfile.id: ${photographerProfile.id}');
        final photographerId = int.tryParse(photographerProfile.id);
        if (photographerId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PhotographerProfilePage(photographerId: photographerId),
            ),
          );
        } else {
          print(
              '[ERROR] photographerProfile.id를 int로 파싱 실패: ${photographerProfile.id}');
        }
      } else {
        print('[ERROR] 로드된 photographerProfile이 null입니다.');
      }
    } catch (e) {
      print('[ERROR] _handleProfileEdit 중 예외 발생: $e');
    }
    print('=================================');
  }

  void _handleBookingHistory(BuildContext context) {
    if (!session.isLogin) {
      LoginRequiredDialog.show(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingManagementScreen(),
      ),
    );
  }

  void _handleReviewManagement(BuildContext context, WidgetRef ref) {
    if (!session.isLogin) {
      LoginRequiredDialog.show(context);
      return;
    }

    UserType userType = UserType.user; // 기본값
    if (session.userTypeCode == 'photographer') {
      userType = UserType.photographer;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewManagerScreen(userType: userType),
      ),
    );
  }

  void _handleHelpCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpCenterScreen(),
      ),
    );
  }
}
