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

  Future<void> _handleProfileEdit(BuildContext context, WidgetRef ref) async {
    print('=== 포토그래퍼 프로필 메뉴 선택 ===');
    try {
      // 1. 내 프로필 정보 로드 또는 갱신
      await ref.read(photographerProfileProvider.notifier).loadMyProfile();

      // 2. 갱신된 프로필 정보 가져오기
      final photographerProfile = ref.read(photographerProfileProvider).profile;
      final errorMessage = ref.read(photographerProfileProvider).errorMessage;

      if (errorMessage != null && errorMessage.isNotEmpty) {
        print('[ERROR] 프로필 로드 실패: $errorMessage');
        // TODO: 사용자에게 오류 메시지 표시 (예: ScaffoldMessenger)
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
          print('[ERROR] photographerProfile.id를 int로 파싱 실패: ${photographerProfile.id}');
          // TODO: 사용자에게 오류 알림
        }
      } else {
        print('[ERROR] 로드된 photographerProfile이 null입니다.');
        // TODO: 사용자에게 프로필 정보를 찾을 수 없다는 알림
      }
    } catch (e) {
      print('[ERROR] _handleProfileEdit 중 예외 발생: $e');
      // TODO: 사용자에게 일반 오류 알림
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
