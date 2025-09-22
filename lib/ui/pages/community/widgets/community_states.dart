import 'package:flutter/material.dart';
import '../../../../_core/constants/app_colors.dart';

/*
 * 커뮤니티 화면의 다양한 상태를 표시하는 위젯들
 * 로딩, 에러, 빈 목록 상태를 관리합니다.
 */

/*
 * 로딩 상태 위젯
 * 게시글을 불러오는 중일 때 표시됩니다.
 */
class CommunityLoadingWidget extends StatelessWidget {
  const CommunityLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            '게시글을 불러오는 중...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * 에러 상태 위젯
 * 게시글 로딩 실패 시 표시됩니다.
 */
class CommunityErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const CommunityErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            '오류가 발생했습니다',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

/*
 * 빈 목록 상태 위젯
 * 게시글이 없을 때 표시됩니다.
 */
class CommunityEmptyWidget extends StatelessWidget {
  const CommunityEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          SizedBox(height: 16),
          Text(
            '게시글이 없습니다',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '첫 번째 게시글을 작성해보세요!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
