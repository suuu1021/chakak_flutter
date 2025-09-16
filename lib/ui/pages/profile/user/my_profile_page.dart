import 'package:chakak_flutter/_core/constants/app_routes.dart';
import 'package:chakak_flutter/ui/pages/booking/booking_management_screen.dart';
import 'package:chakak_flutter/ui/pages/review/review_manager_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../_core/constants/user_type.dart';
import '../../../../provider/global/user_profile/user_profile_provider.dart';
import '../../../../provider/auth/session_provider.dart';
import '../../help_center/help_center_screen.dart';
import 'widgets/logout_dialog.dart';

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

  // 로그인 필요 팝업
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          '로그인이 필요합니다',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('이 기능을 사용하려면 로그인이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final profileState = ref.watch(userProfileProvider);

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
              _buildProfileHeader(session, profileState),
              const SizedBox(height: AppSizes.spacing24),
              _buildMenuList(context, session),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      AppSession session, UserProfileState profileState) {
    // 로그인하지 않은 경우
    if (!session.isLogin) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 기본 프로필 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(width: AppSizes.spacing16),
            // 로그인 필요 메시지
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.loginChoice);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '로그인이 필요합니다',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      '프로필 정보를 확인하려면 로그인해주세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 로그인한 경우 기존 로직
    if (profileState.isLoading) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(AppSizes.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (profileState.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              profileState.errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  ref.read(userProfileProvider.notifier).loadMyProfile(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final profile = profileState.profile;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(40),
              image: profile?.hasProfileImage == true
                  ? DecorationImage(
                      image: NetworkImage(profile!.imageData!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profile?.hasProfileImage != true
                ? Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.gray500,
                  )
                : null,
          ),
          const SizedBox(width: AppSizes.spacing16),
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.displayName ?? '사용자',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  profile?.userEmail ?? 'email@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  profile?.formattedIntroduce ?? '소개글이 없습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    profile?.userTypeName ?? '일반 회원',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 편집 버튼
          IconButton(
            onPressed: () {
              _showProfileEditDialog(context, profile);
            },
            icon: const Icon(Icons.edit),
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }

  void _showProfileEditDialog(BuildContext context, profile) {
    // 프로필 편집 다이얼로그 또는 페이지로 이동
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 편집'),
        content: const Text('프로필 편집 기능을 구현해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, AppSession session) {
    final menuItems = [
      {
        'icon': Icons.history,
        'title': '예약 내역',
        'subtitle': '지난 예약 내역을 확인하세요',
        'requireLogin': true,
        'onTap': () {
          if (!session.isLogin) {
            _showLoginRequiredDialog(context);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookingManagementScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.star,
        'title': '리뷰 관리',
        'subtitle': '작성한 리뷰를 관리하세요',
        'requireLogin': true,
        'onTap': () {
          if (!session.isLogin) {
            _showLoginRequiredDialog(context);
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
        },
      },
      {
        'icon': Icons.help,
        'title': '고객센터',
        'subtitle': '문의사항이 있으시면 연락주세요',
        'requireLogin': false,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpCenterScreen(),
              ),
            ),
      },
      if (session.isLogin)
        {
          'icon': Icons.logout,
          'title': '로그아웃',
          'subtitle': '계정에서 로그아웃합니다',
          'requireLogin': false,
          'onTap': () => LogoutDialog.show(context),
        },
    ];

    return Column(
      children: menuItems
          .map((item) => _buildMenuItem(
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
                onTap: item['onTap'] as VoidCallback,
              ))
          .toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.gray400,
        ),
        onTap: onTap,
      ),
    );
  }
}
