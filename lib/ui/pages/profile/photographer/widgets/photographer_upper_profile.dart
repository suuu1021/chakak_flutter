import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_images.dart';
import '../../../../../_core/constants/app_routes.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../../data/dtos/chat_room_create_request_dto.dart';
import '../../../../../provider/auth/session_provider.dart';
import '../../../../../provider/chat/chat_provider.dart';
import '../../../../../provider/global/photographer/photographer_provider.dart';
import '../../../../../provider/global/photographer_profile/photographer_profile_notifier.dart';
import '../../../chat/chat_screen.dart';

class PhotographerUpperProfile extends ConsumerStatefulWidget {
  final int photographerId;

  const PhotographerUpperProfile({
    super.key,
    required this.photographerId,
  });

  @override
  ConsumerState<PhotographerUpperProfile> createState() =>
      _PhotographerUpperProfileState();
}

class _PhotographerUpperProfileState
    extends ConsumerState<PhotographerUpperProfile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(photographerProfileProvider.notifier)
          .loadProfileById(widget.photographerId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(photographerProfileProvider);

    return Column(
      children: [
        _buildProfileSection(context, profileState),
        const SizedBox(height: AppSizes.spacing12),
        _buildStatsCard(profileState),
      ],
    );
  }

  Widget _buildProfileSection(
      BuildContext context, PhotographerProfileState profileState) {
    final session = ref.watch(sessionProvider); // 세션 정보 가져오기

    // 현재 로그인한 포토그래퍼가 자신의 프로필을 보고 있는지 확인
    final isOwner = session.isLogin &&
        session.userTypeCode == 'photographer' &&
        profileState.profile != null &&
        session.userId.toString() == profileState.profile!.userId;

    return Row(
      children: [
        _buildProfileImage(profileState),
        const SizedBox(width: AppSizes.spacing16),
        Expanded(child: _buildProfileInfo(profileState)),
        const SizedBox(width: AppSizes.spacing16),
        if (isOwner) // 조건부 렌더링으로 설정 아이콘 표시
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.photographerProfileForm);
            },
            icon: const Icon(Icons.edit),
          )
        else if (session.isLogin) // 로그인했고 본인이 아닐 때 채팅 아이콘
          IconButton(
            onPressed: () => _onChatTap(context),
            icon: const Icon(Icons.chat),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage(PhotographerProfileState profileState) {
    final imageUrl = profileState.profile?.profileImageUrl;

    return CircleAvatar(
      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : const AssetImage(AppImages.photographerProfile) as ImageProvider,
      maxRadius: 40,
      minRadius: 20,
      backgroundColor: AppColors.gray200,
      onBackgroundImageError: imageUrl != null
          ? (exception, stackTrace) =>
              const AssetImage(AppImages.photographerProfile)
          : null,
    );
  }

  Widget _buildProfileInfo(PhotographerProfileState profileState) {
    if (profileState.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoadingShimmer(width: 120, height: 16),
          const SizedBox(height: 4),
          _buildLoadingShimmer(width: 80, height: 14),
          const SizedBox(height: 4),
          _buildLoadingShimmer(width: 150, height: 12),
          const SizedBox(height: 4),
          _buildLoadingShimmer(width: 100, height: 12),
        ],
      );
    }

    if (profileState.profile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profileState.errorMessage ?? '프로필 정보 없음',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.error,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUsername(profileState.profile!.businessName),
        _buildRatingSection(),
        _buildLocation(profileState.profile!.location),
        // _buildExperience(profileState.profile!.experienceYears),
        _buildHashTags(profileState.profile!.categories),
      ],
    );
  }

  Widget _buildLoadingShimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildUsername(String businessName) {
    return Text(
      businessName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: AppColors.warning,
          size: 16,
        ),
        const SizedBox(width: 4),
        const Text(
          '4.0',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '(109)',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(String location) {
    return Text(
      '활동 지역: $location',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }

  // Widget _buildExperience(int? experienceYears) {
  //   return Text(
  //     '경력: ${experienceYears ?? 0}년',
  //     style: const TextStyle(
  //       fontSize: 12,
  //       color: AppColors.textSecondary,
  //     ),
  //   );
  // }

  Widget _buildHashTags(List<dynamic>? categories) {
    if (categories == null || categories.isEmpty) {
      return const Text(
        '#포토그래퍼',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final categoryNames = categories
        .take(3) // 최대 3개만 표시
        .map((category) => '#${category.name ?? category.toString()}')
        .join(', ');

    return Text(
      categoryNames,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildStatsCard(PhotographerProfileState profileState) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing6),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('거래건수', '797건'),
          _buildVerticalDivider(),
          _buildStatItem('만족도', '98%'),
          _buildVerticalDivider(),
          _buildStatItem(
              '경력', '${profileState.profile?.experienceYears ?? 0}년'),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.gray300,
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _onChatTap(BuildContext context) async {
    try {
      final session = ref.read(sessionProvider);

      // 포토그래퍼 정보 조회
      final photographer = ref
          .read(photographerProvider.notifier)
          .getPhotographerById(widget.photographerId);

      // 채팅방 생성/조회 요청
      final chatRequest = ChatRoomCreateRequestDto(
        photographerProfileId: widget.photographerId,
        userProfileId: session.userId,
      );

      final chatRoom = await ref
          .read(chatRepositoryProvider)
          .createOrGetChatRoom(chatRequest);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoom.chatRoomId,
            opponentNickname: photographer?.businessName ?? "포토그래퍼",
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('채팅 연결 중 오류가 발생했습니다')),
      );
    }
  }
}
