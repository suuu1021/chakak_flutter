import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../../_core/constants/app_routes.dart';
import '../../../../../_core/utils/image_utils.dart';
import '../../../../../provider/global/photographer_profile/photographer_profile_notifier.dart';
import '../../../../../provider/global/user_profile/user_profile_provider.dart';
import '../../../../../provider/auth/session_provider.dart';
import '../../photographer/photographer_profile_form_page.dart';
import '../profile_form_page.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  final AppSession session;

  const ProfileHeader({super.key, required this.session});

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  @override
  void initState() {
    super.initState();
    if (widget.session.isLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProfileByUserType();
      });
    }
  }

  void _loadProfileByUserType() {
    final rawType = widget.session.userTypeCode;
    if (rawType == null) {
      print('[DEBUG] userTypeCode 아직 없음 -> 프로필 로드 건너뜀');
      return;
    }

    final userType = rawType.toUpperCase();
    print('현재 사용자 타입: $rawType -> $userType'); // 디버그 로그 추가

    if (userType == 'PHOTOGRAPHER') {
      print('포토그래퍼 프로필 API 호출');
      ref.read(photographerProfileProvider.notifier).loadMyProfile();
    } else {
      print('일반 사용자 프로필 API 호출');
      ref.read(userProfileProvider.notifier).loadMyProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.session.isLogin) {
      return _buildGuestHeader(context);
    }

    final userType = widget.session.userTypeCode?.toUpperCase();

    if (userType == 'PHOTOGRAPHER') {
      final pState = ref.watch(photographerProfileProvider);

      if (pState.isLoading) return _buildLoadingHeader();
      if (pState.errorMessage != null)
        return _buildErrorHeader(context, ref, pState.errorMessage!);

      final profile = pState.profile;

      // 포토그래퍼용 헤더 렌더링
      return Container(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        decoration: _headerDecoration(),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(40),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: profile?.profileImageUrl != null
                    ? ImageUtils.buildSafeImage(
                        profile!.profileImageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.person, size: 40, color: AppColors.gray500),
              ),
            ),
            const SizedBox(width: AppSizes.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.businessName ?? '사진작가',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSizes.spacing4),
                  Text(
                    profile?.location ?? '-',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSizes.spacing4),
                  Text(
                    profile?.introduction ?? '소개글이 없습니다.',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PhotographerProfileFormPage()),
              ).then((success) {
                if (success == true) {
                  ref
                      .read(photographerProfileProvider.notifier)
                      .loadMyProfile();
                }
              }),
              icon: const Icon(Icons.edit),
              color: AppColors.gray600,
            ),
          ],
        ),
      );
    }

    // 기본: 일반 유저 헤더
    final profileState = ref.watch(userProfileProvider);

    if (profileState.isLoading) {
      return _buildLoadingHeader();
    }

    if (profileState.errorMessage != null) {
      return _buildErrorHeader(context, ref, profileState.errorMessage!);
    }

    return _buildUserHeader(context, ref, profileState.profile);
  }
}

Widget _buildGuestHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(AppSizes.spacing16),
    decoration: _headerDecoration(),
    child: Row(
      children: [
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
          onPressed: () {
            final session = ref.read(sessionProvider);
            final userType = session.userTypeCode?.toUpperCase();
            if (userType == 'PHOTOGRAPHER') {
              ref.read(photographerProfileProvider.notifier).loadMyProfile();
            } else {
              ref.read(userProfileProvider.notifier).loadMyProfile();
            }
          },
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

Widget _buildUserHeader(BuildContext context, WidgetRef ref, profile) {
  return Container(
    padding: const EdgeInsets.all(AppSizes.spacing16),
    decoration: _headerDecoration(),
    child: Row(
      children: [
        _buildProfileImage(profile),
        const SizedBox(width: AppSizes.spacing16),
        Expanded(
          child: _buildUserInfo(profile),
        ),
        IconButton(
          onPressed: () => _showProfileEditDialog(context, ref, profile),
          icon: const Icon(Icons.edit),
          color: AppColors.gray600,
        ),
      ],
    ),
  );
}

Widget _buildProfileImage(profile) {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: AppColors.gray200,
      borderRadius: BorderRadius.circular(40),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: profile?.hasProfileImage == true
          ? ImageUtils.buildSafeImage(
              profile!.imageData!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            )
          : Icon(Icons.person, size: 40, color: AppColors.gray500),
    ),
  );
}

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

Widget _buildUserTypeBadge(String userType) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: AppColors.primary.withAlpha(25),
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

void _showProfileEditDialog(BuildContext context, WidgetRef ref, profile) {
  if (profile != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileFormPage(
          userProfile: profile,
        ),
      ),
    ).then((success) {
      if (success == true) {
        ref.read(userProfileProvider.notifier).loadMyProfile();
      }
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로필 정보를 불러오는 중입니다.')),
    );
  }
}
