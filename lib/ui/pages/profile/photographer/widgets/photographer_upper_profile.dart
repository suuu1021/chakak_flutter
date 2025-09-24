import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_images.dart';
import '../../../../../_core/constants/app_routes.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../../data/dtos/chat_room_create_request_dto.dart';
import '../../../../../data/models/photographer_profile.dart';
import '../../../../../data/models/repositories/photographer_profile_repository.dart';
import '../../../../../provider/auth/session_provider.dart';
import '../../../../../provider/chat/chat_provider.dart';
import '../../../../../provider/core/dio_provider.dart';
import '../../../../../provider/global/photographer/photographer_provider.dart';
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
  // 로컬 상태 변수들 - 전역 상태와 완전히 분리
  PhotographerProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPhotographerProfile();
  }

  // API를 직접 호출하여 로컬 변수에만 저장
  Future<void> _loadPhotographerProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final repository = PhotographerProfileRepositoryImpl(dio);
      final session = ref.read(sessionProvider);

      // 마이페이지인지 정확히 판단: photographerId가 정확히 일치해야 함
      // (단순히 photographer 타입인지가 아니라, 실제 같은 사람인지 확인)

      // 현재 로그인한 사용자의 photographer 정보가 필요
      // 일단 ID로 조회하고, 나중에 userId 비교로 마이페이지 여부 확인
      final profile =
          await repository.getProfile(widget.photographerId.toString());

      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileSection(context),
        const SizedBox(height: AppSizes.spacing12),
        _buildStatsCard(),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final session = ref.watch(sessionProvider);

    // 현재 로그인한 포토그래퍼가 자신의 프로필을 보고 있는지 확인
    final isOwner = session.isLogin &&
        session.userTypeCode == 'photographer' &&
        _profile != null &&
        session.userId.toString() == _profile!.userId.toString();

    return Row(
      children: [
        _buildProfileImage(),
        const SizedBox(width: AppSizes.spacing16),
        Expanded(child: _buildProfileInfo()),
        const SizedBox(width: AppSizes.spacing16),
        if (isOwner)
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.photographerProfileForm);
            },
            icon: const Icon(Icons.edit),
          )
        else if (session.isLogin)
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

  Widget _buildProfileImage() {
    final imageUrl = _profile?.profileImageUrl;

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

  Widget _buildProfileInfo() {
    if (_isLoading) {
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

    if (_profile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _errorMessage ?? '프로필 정보 없음',
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
        _buildUsername(_profile!.businessName),
        _buildRatingSection(),
        _buildLocation(_profile!.location),
        _buildHashTags(_profile!.categories),
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
        .take(3)
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

  Widget _buildStatsCard() {
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
          _buildStatItem('경력', '${_profile?.experienceYears ?? 0}년'),
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
