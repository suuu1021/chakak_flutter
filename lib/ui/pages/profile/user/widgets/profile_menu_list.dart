import 'package:chakak_flutter/provider/global/photographer_profile/photographer_profile_notifier.dart';
import 'package:chakak_flutter/ui/pages/profile/photographer/photographer_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/user_type.dart';
import '../../../../../provider/auth/session_provider.dart';
import '../../../../../provider/global/user_profile/user_profile_provider.dart';
import '../../../booking/booking_management_screen.dart';
import '../../../help_center/help_center_screen.dart';
import '../../../review/review_manager_screen.dart';
import '../profile_form_page.dart'; // 프로필 수정 페이지 import
import 'profile_menu_item.dart';
import 'login_required_dialog.dart';
import 'logout_dialog.dart';
import 'withdrawal_dialog.dart'; // 회원 탈퇴 다이얼로그 import

class ProfileMenuList extends ConsumerWidget {
  final AppSession session;

  const ProfileMenuList({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = _buildMenuItems(context, ref);

    // Column을 ListView.separated로 변경하여 구분선 추가
    return ListView.builder(
      shrinkWrap: true,
      // Column처럼 동작하도록 설정
      physics: const NeverScrollableScrollPhysics(),
      // 스크롤 비활성화
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
        'subtitle': '작성한 리뷰를 관리하세요',
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

  void _handleProfileEdit(BuildContext context, WidgetRef ref) {
    final photographerProfile = ref.read(photographerProfileProvider).profile;
    if (photographerProfile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotographerProfilePage(
              photographerId: int.parse(photographerProfile.id)),
        ),
      );
    } else {
      // 프로필 정보가 아직 로드되지 않았을 경우의 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
      );
    }
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

    final profile = ref.read(userProfileProvider).profile;
    final userTypeString = profile?.userTypeName ?? 'user';

    UserType userType = userTypeString.toLowerCase() == 'photographer'
        ? UserType.photographer
        : UserType.user;

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
