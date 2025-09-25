import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../_core/constants/app_sizes.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';
import '../../../../../../data/models/photographer_profile.dart';
import '../../../../../../data/models/repositories/photographer_profile_repository.dart';
import '../../../../_core/utils/image_utils.dart';
import '../../../../provider/core/dio_provider.dart';

class PhotographerInfoSection extends ConsumerStatefulWidget {
  final PhotoService service;
  final VoidCallback? onProfileTap;

  const PhotographerInfoSection({
    super.key,
    required this.service,
    this.onProfileTap,
  });

  @override
  ConsumerState<PhotographerInfoSection> createState() =>
      _PhotographerInfoSectionState();
}

class _PhotographerInfoSectionState
    extends ConsumerState<PhotographerInfoSection> {
  // 🔥 로컬 상태 변수들 - 전역 상태와 완전히 분리
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
      final photographerId = widget.service.photographerId.toString();

      final profile = await repository.getProfile(photographerId);

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
    return Container(
      margin: const EdgeInsets.all(AppSizes.spacing16),
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
          _buildProfileImage(_profile?.profileImageUrl),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: _buildPhotographerInfo(),
          ),
          _buildProfileButton(),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: ImageUtils.buildSafeImage(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          : const Icon(
              Icons.person,
              size: 30,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildPhotographerInfo() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSizes.spacing4),
          Container(
            width: 150,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null || _profile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '포토그래퍼',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacing4),
          Text(
            '정보를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    final profile = _profile!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.businessName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.spacing4),
        Text(
          '${profile.location} • ${profile.experienceYears ?? 0}년 경력',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return TextButton(
      onPressed: widget.onProfileTap ?? _defaultProfileTap,
      child: const Text('프로필 보기'),
    );
  }

  void _defaultProfileTap() {
    print('프로필 보기 - photographerId: ${widget.service.photographerId}');
  }
}
