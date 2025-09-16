import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../../_core/constants/app_routes.dart';
import '../../../../../provider/global/user_profile/user_profile_provider.dart';
import '../../../../../provider/auth/session_provider.dart';

class ProfileHeader extends ConsumerWidget {
  final AppSession session;

  const ProfileHeader({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!session.isLogin) {
      return _buildGuestHeader(context);
    }

    final profileState = ref.watch(userProfileProvider);

    if (profileState.isLoading) {
      return _buildLoadingHeader();
    }

    if (profileState.errorMessage != null) {
      return _buildErrorHeader(context, ref, profileState.errorMessage!);
    }

    return _buildUserHeader(context, profileState.profile);
  }

  // 비로그인 사용자 헤더
  Widget _buildGuestHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: _headerDecoration(),
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
              onTap: () => Navigator.pushNamed(context, AppRoutes.loginChoice),
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

  // 로딩 상태 헤더
  Widget _buildLoadingHeader() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: _headerDecoration(),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // 에러 상태 헤더
  Widget _buildErrorHeader(
      BuildContext context, WidgetRef ref, String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: _headerDecoration(),
      child: Column(
        children: [
          Text(
            errorMessage,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing8),
          ElevatedButton(
            onPressed: () =>
                ref.read(userProfileProvider.notifier).loadMyProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  // 로그인된 사용자 헤더
  Widget _buildUserHeader(BuildContext context, profile) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: _headerDecoration(),
      child: Row(
        children: [
          // 프로필 이미지
          _buildProfileImage(profile),
          const SizedBox(width: AppSizes.spacing16),
          // 사용자 정보
          Expanded(
            child: _buildUserInfo(profile),
          ),
          // 편집 버튼
          IconButton(
            onPressed: () => _showProfileEditDialog(context, profile),
            icon: const Icon(Icons.edit),
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }

  // 프로필 이미지 위젯
  Widget _buildProfileImage(profile) {
    return Container(
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
    );
  }

  // 사용자 정보 위젯
  Widget _buildUserInfo(profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile?.displayName ?? '사용자',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing4),
        Text(
          profile?.userEmail ?? 'email@example.com',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing4),
        Text(
          profile?.formattedIntroduce ?? '소개글이 없습니다.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSizes.spacing8),
        _buildUserTypeBadge(profile?.userTypeName ?? '일반 회원'),
      ],
    );
  }

  // 사용자 타입 배지
  Widget _buildUserTypeBadge(String userType) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        userType,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 공통 헤더 데코레이션
  BoxDecoration _headerDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // 프로필 편집 다이얼로그
  void _showProfileEditDialog(BuildContext context, profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '프로필 편집',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '프로필 편집 기능을 구현해주세요.',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: TextStyle(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
