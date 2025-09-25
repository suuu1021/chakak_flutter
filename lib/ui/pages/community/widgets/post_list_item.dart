/*
 * 개별 게시글 아이템 위젯
 * 커뮤니티 목록에서 각 게시글을 표시하는 재사용 가능한 컴포넌트
 */
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../data/models/community/post.dart';

class PostListItem extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostListItem({
    super.key,
    required this.post,
    required this.onTap,
  });

  /*
   * 카테고리에 따른 색상 반환
   */
  Color _getCategoryColor(String? category) {
    switch (category) {
      case '공지':
        return AppColors.error;
      case '추천':
        return AppColors.primary;
      default:
        return AppColors.accent;
    }
  }

  /*
   * 썸네일 처리 (http URL + Base64 Data URL 모두 지원)
   */
  Widget _buildThumbnail(String? dataUrl) {
    if (dataUrl == null || dataUrl.isEmpty) {
      return const Icon(Icons.image_not_supported,
          color: AppColors.gray400, size: 24);
    }

    try {
      // http/https 일반 URL 처리
      if (dataUrl.startsWith('http')) {
        return Image.network(
          dataUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image,
                color: AppColors.gray400, size: 24);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray400),
                ),
              ),
            );
          },
        );
      }

      // data:image/png;base64,... 형태 처리
      final base64Str = dataUrl.split(',').last;
      final bytes = base64Decode(base64Str);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image,
              color: AppColors.gray400, size: 24);
        },
      );
    } catch (e) {
      return const Icon(Icons.broken_image, color: AppColors.gray400, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 게시글 상세 페이지로 이동할 때 애니메이션을 위해 Hero 위젯을 추가했습니다.
    // 태그는 각 게시글의 고유 ID를 사용해야 합니다.
    return Hero(
      tag: 'post-${post.id}', // post.id는 각 게시글마다 고유해야 합니다.
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: AppColors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 왼쪽 콘텐츠
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 카테고리 태그
                              if (post.category != null &&
                                  (post.category == '공지' ||
                                      post.category == '추천')) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(post.category),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    post.category!,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],

                              // 제목
                              Expanded(
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // 메타 정보
                          Row(
                            children: [
                              // 댓글수
                              Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline,
                                      color: AppColors.secondary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    post.replyCount.toString(),
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // 작성자
                              Text(
                                post.author,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              if (post.authorBadge.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Text(
                                  post.authorBadge,
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(width: 12),
                              // 조회수
                              Row(
                                children: [
                                  const Icon(Icons.visibility_outlined,
                                      color: AppColors.textTertiary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    post.viewCount.toString(),
                                    style: const TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // 시간
                              Text(
                                post.timeAgo,
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 썸네일 (있는 경우)
                    if (post.imageUrl != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          // 교체: _buildThumbnail(post.imageUrl)
                          child: _buildThumbnail(post.imageUrl),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 구분선
              Container(
                height: 1,
                color: AppColors.divider,
                margin: const EdgeInsets.only(left: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
