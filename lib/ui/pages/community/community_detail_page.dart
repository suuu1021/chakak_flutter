import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../_core/constants/app_colors.dart';
import '../../../data/models/community/post.dart';
import '../../../provider/global/community/post_provider.dart';
import '../../../provider/global/community/reply_provider.dart';
import 'widgets/community_states.dart';
import 'widgets/post_detail_header.dart';
import 'widgets/reply_section.dart';
import 'widgets/reply_input.dart';

/*
 * 커뮤니티 게시글 상세 페이지
 * 기존 UI 스타일을 유지하면서 실제 Provider와 Model을 사용합니다.
 */
class CommunityDetailPage extends ConsumerStatefulWidget {
  final String postId;

  const CommunityDetailPage({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<CommunityDetailPage> createState() =>
      _CommunityDetailPageState();
}

class _CommunityDetailPageState extends ConsumerState<CommunityDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 댓글 목록을 가져옵니다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(replyProvider.notifier).loadReplies(widget.postId);
    });
  }

  /*
   * 댓글 전송 처리
   */
  void _onSendReply() {
    if (_commentController.text.trim().isNotEmpty) {
      // TODO: 댓글 작성 기능 구현
      final content = _commentController.text.trim();
      // ref.read(replyProvider.notifier).createReply(widget.postId, Reply(...))
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 작성 기능은 준비 중입니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postDetail = ref.watch(postDetailProvider(widget.postId));
    final replyState = ref.watch(replyProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '커뮤니티',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.white),
            onPressed: () {
              // Share.share()에 post 객체 사용
              postDetail.when(
                data: (post) {
                  Share.share(
                    '게시물 제목: ${post.title}\n\n내용: ${post.content}',
                  );
                },
                loading: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시물 정보를 불러오는 중입니다.')),
                ),
                error: (error, stack) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시물 정보를 불러올 수 없습니다.')),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onPressed: () {
              // TODO: 메뉴 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('메뉴 기능은 준비 중입니다')),
              );
            },
          ),
        ],
      ),
      body: postDetail.when(
        data: (post) => _buildContent(post, replyState),
        loading: () => const CommunityLoadingWidget(),
        error: (error, stack) => CommunityErrorWidget(
          error: error.toString(),
          onRetry: () => ref.invalidate(postDetailProvider(widget.postId)),
        ),
      ),
    );
  }

  /*
   * 게시글과 댓글을 표시하는 메인 콘텐츠
   */
  Widget _buildContent(Post post, ReplyState replyState) {
    return Column(
      children: [
        // 게시글 내용 영역
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 게시글 헤더, 본문, 액션 버튼
                PostDetailHeader(post: post),
                // 댓글 섹션
                ReplySection(replyState: replyState),
              ],
            ),
          ),
        ),
        // 댓글 입력 영역
        ReplyInput(
          controller: _commentController,
          onSend: _onSendReply,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
