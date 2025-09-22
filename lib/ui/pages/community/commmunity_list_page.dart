import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/constants/app_colors.dart';
import '../../../provider/global/community/post_provider.dart';
import 'community_detail_page.dart';
import 'widgets/community_states.dart';
import 'widgets/post_list_item.dart';

/*
 * 커뮤니티 게시글 목록을 표시하는 메인 페이지
 * 기존 UI 스타일을 유지하면서 실제 Provider와 Model을 사용합니다.
 */
class CommunityListPage extends ConsumerStatefulWidget {
  const CommunityListPage({super.key});

  @override
  ConsumerState<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends ConsumerState<CommunityListPage> {
  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 게시글 목록을 가져옵니다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postProvider.notifier).loadPosts();
    });
  }

  /*
   * 새로고침 처리
   */
  Future<void> _onRefresh() async {
    await ref.read(postProvider.notifier).loadPosts();
  }

  /*
   * 게시글 상세 페이지로 이동
   */
  void _navigateToDetail(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityDetailPage(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // 제목 섹션 (기존 스타일과 동일)
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '스냅촬영 커뮤니티',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '사진작가 추천, 장소 정보, 후기를 공유해요',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // 게시글 목록 영역
          Expanded(
            child: _buildBody(postState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 글쓰기 페이지 구현 후 연결
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('글쓰기 기능은 준비 중입니다')),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit, color: AppColors.white),
      ),
    );
  }

  /*
   * 상태에 따른 Body 위젯 구성
   */
  Widget _buildBody(PostState postState) {
    if (postState.isLoading && postState.posts.isEmpty) {
      return const CommunityLoadingWidget();
    }

    if (postState.error != null && postState.posts.isEmpty) {
      return CommunityErrorWidget(
        error: postState.error!,
        onRetry: () => ref.read(postProvider.notifier).loadPosts(),
      );
    }

    if (postState.posts.isEmpty) {
      return const CommunityEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: [
          // 에러 메시지 표시 (목록이 있을 때)
          if (postState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Text(
                postState.error!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),

          // 로딩 인디케이터 (목록이 있을 때)
          if (postState.isLoading)
            const LinearProgressIndicator(
              backgroundColor: AppColors.gray100,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

          // 게시글 목록
          Expanded(
            child: ListView.builder(
              itemCount: postState.posts.length,
              itemBuilder: (context, index) {
                final post = postState.posts[index];
                return PostListItem(
                  post: post,
                  onTap: () => _navigateToDetail(post.id),
                  onLikeTap: () =>
                      ref.read(postProvider.notifier).togglePostLike(post.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
