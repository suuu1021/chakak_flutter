import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../data/models/community/post.dart';
import '../../../../provider/global/community/post_provider.dart';

/*
 * 게시글 상세 페이지의 헤더, 본문, 액션 버튼을 포함하는 위젯
 * 게시글의 주요 정보와 상호작용 요소들을 담당합니다.
 */
class PostDetailHeader extends ConsumerStatefulWidget {
  final Post post;

  const PostDetailHeader({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<PostDetailHeader> createState() => _PostDetailHeaderState();
}

class _PostDetailHeaderState extends ConsumerState<PostDetailHeader> {
  bool isBookmarked = false; // TODO: 북마크 상태 관리 추가 예정

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 게시글 헤더
        _buildPostHeader(),
        // 게시글 본문
        _buildPostContent(),
        // 좋아요/북마크 버튼
        _buildActionButtons(),
      ],
    );
  }

  /*
   * 게시글 헤더 (기존 스타일 적용)
   */
  Widget _buildPostHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 태그
          if (widget.post.category != null && widget.post.category!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.post.category!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // 제목
          Text(
            widget.post.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // 작성자 정보
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.post.author,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.post.authorBadge.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  widget.post.authorBadge,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                widget.post.timeAgo,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*
   * 게시글 본문
   */
  Widget _buildPostContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.content,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          // 이미지가 있는 경우
          if (widget.post.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: AppColors.gray100,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.gray400,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /*
   * 좋아요/북마크 액션 버튼
   */
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider),
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          // 좋아요 버튼
          GestureDetector(
            onTap: () {
              ref.read(postProvider.notifier).togglePostLike(widget.post.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    widget.post.isLiked ? AppColors.primary : AppColors.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.post.isLiked
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    color: widget.post.isLiked
                        ? AppColors.white
                        : AppColors.gray600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.post.likeCount.toString(),
                    style: TextStyle(
                      color: widget.post.isLiked
                          ? AppColors.white
                          : AppColors.gray600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 북마크 버튼
          GestureDetector(
            onTap: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });
              // TODO: 북마크 API 연동
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isBookmarked ? AppColors.secondary : AppColors.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    color: isBookmarked ? AppColors.white : AppColors.gray600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '북마크',
                    style: TextStyle(
                      color: isBookmarked ? AppColors.white : AppColors.gray600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
}
