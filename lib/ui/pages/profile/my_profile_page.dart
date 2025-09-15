import 'package:flutter/material.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppSizes.spacing24),
            _buildMenuList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '김사용자',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '일반 회원',
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
              print('프로필 편집');
            },
            icon: const Icon(Icons.edit),
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    final menuItems = [
      {
        'icon': Icons.bookmark,
        'title': '찜한 서비스',
        'subtitle': '관심있는 서비스를 확인하세요'
      },
      {'icon': Icons.history, 'title': '예약 내역', 'subtitle': '지난 예약 내역을 확인하세요'},
      {'icon': Icons.camera_alt, 'title': '내 사진', 'subtitle': '촬영된 사진들을 확인하세요'},
      {'icon': Icons.star, 'title': '리뷰 관리', 'subtitle': '작성한 리뷰를 관리하세요'},
      {
        'icon': Icons.notifications,
        'title': '알림 설정',
        'subtitle': '알림 설정을 변경하세요'
      },
      {'icon': Icons.help, 'title': '고객센터', 'subtitle': '문의사항이 있으시면 연락주세요'},
      {'icon': Icons.settings, 'title': '설정', 'subtitle': '앱 설정을 변경하세요'},
    ];

    return Column(
      children: menuItems
          .map((item) => _buildMenuItem(
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
              ))
          .toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
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
        onTap: () {
          print('$title 클릭');
        },
      ),
    );
  }
}
