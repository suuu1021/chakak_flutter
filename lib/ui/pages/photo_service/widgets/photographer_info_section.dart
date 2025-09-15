import 'package:flutter/material.dart';
import '../../../../../../_core/constants/app_sizes.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';

class PhotographerInfoSection extends StatelessWidget {
  final PhotoService service;
  final VoidCallback? onProfileTap;

  const PhotographerInfoSection({
    super.key,
    required this.service,
    this.onProfileTap,
  });

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
          _buildProfileImage(),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(child: _buildPhotographerInfo()),
          _buildProfileButton(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Icon(
        Icons.person,
        size: 30,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildPhotographerInfo() {
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
          '전문 사진작가',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return TextButton(
      onPressed: onProfileTap ?? _defaultProfileTap,
      child: const Text('프로필 보기'),
    );
  }

  void _defaultProfileTap() {
    print('프로필 보기 - photographerId: ${service.photographerId}');
  }
}
