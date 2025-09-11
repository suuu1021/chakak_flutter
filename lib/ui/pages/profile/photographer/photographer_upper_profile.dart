import 'package:flutter/material.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_images.dart';
import '../../../../_core/constants/app_sizes.dart';

class PhotographerUpperProfile extends StatelessWidget {
  const PhotographerUpperProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileSection(),
        const SizedBox(height: AppSizes.spacing12),
        _buildScheduleButton(),
        const SizedBox(height: AppSizes.spacing12),
        _buildStatsCard(),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        _buildProfileImage(),
        const SizedBox(width: AppSizes.spacing16),
        Expanded(child: _buildProfileInfo()),
      ],
    );
  }

  Widget _buildProfileImage() {
    return const CircleAvatar(
      backgroundImage: AssetImage(AppImages.photographerProfile),
      maxRadius: 40,
      minRadius: 20,
      backgroundColor: AppColors.gray200,
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUsername(),
        _buildRatingSection(),
        _buildWorkingHours(),
        _buildResponseTime(),
        _buildHashTags(),
      ],
    );
  }

  Widget _buildUsername() {
    return const Text(
      'PhotographerUsername',
      style: TextStyle(
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

  Widget _buildWorkingHours() {
    return const Text(
      '연락가능시간 : 10:00 ~ 18:00',
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildResponseTime() {
    return const Text(
      '평균응답시간 : 1시간 이내',
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildHashTags() {
    return const Text(
      '#데일리 포토, #스냅샷, #인생샷',
      style: TextStyle(
        fontSize: 12,
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Widget _buildScheduleButton() {
  //   return CustomElevatedButton(
  //     text: '스케쥴 관리',
  //     click: () => print('스케쥴 관리 클릭'),
  //   );
  // }
  Widget _buildScheduleButton() {
    return Container(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () => print('스케줄 관리 클릭'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // #F4A460 골든 아워 샌디 브라운
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        ),
        child: const Text(
          '스케줄 관리',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing6),
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('거래건수', '797건'),
          _buildVerticalDivider(),
          _buildStatItem('만족도', '98%'),
          _buildVerticalDivider(),
          _buildStatItem('회원 구분', '개인 작가'),
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
}
