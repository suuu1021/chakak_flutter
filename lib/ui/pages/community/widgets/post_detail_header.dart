import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../data/models/community/post.dart';
import '../../../../provider/global/community/post_provider.dart';

/*
 * 게시글 상세 페이지의 헤더, 본문, 액션 버튼을 포함하는 위젯
 * 이제 이 위젯은 데이터 상태를 '표시'하는 역할에만 집중합니다.
 */
class PostDetailHeader extends ConsumerWidget {
  final String postId;

  const PostDetailHeader({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PostProvider에서 현재 게시글의 최신 상태를 watch합니다.
    final postState = ref.watch(postProvider);
    final currentPost = postState.findPostById(postId);

    // 데이터가 아직 상태에 없다면 로딩 인디케이터를 표시합니다.
    if (currentPost == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPostHeader(currentPost),
        _buildPostContent(currentPost),
        const Divider(color: AppColors.gray200),
      ],
    );
  }

  /*
  * 게시글 헤더 (작성자, 작성일)
  */
  Widget _buildPostHeader(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.gray100,
            // child: Icon(Icons.person, color: AppColors.gray400), // 프로필 이미지 추가 시 대체
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.author,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                post.timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (post.authorBadge.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                post.authorBadge,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /*
  * 게시글 본문
  */
  Widget _buildPostContent(Post post) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        post.content,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }
}
