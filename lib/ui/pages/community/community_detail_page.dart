import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../_core/constants/app_colors.dart';
import '../../../data/models/community/post.dart';
import '../../../data/models/community/reply.dart';
import '../../../provider/auth/session_provider.dart';
import '../../../provider/global/community/post_provider.dart';
import '../../../provider/global/community/reply_provider.dart';
import 'community_form_page.dart';
import 'widgets/community_states.dart';
import 'widgets/post_detail_header.dart';
import 'widgets/reply_section.dart';
import 'widgets/reply_input.dart';

/*
 * 커뮤니티 게시글 상세 페이지
 * 단일 데이터 소스(postProvider)만 사용하여 상태 관리 단순화
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
  bool _isPostLoaded = false;

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 필요한 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPostData();
      ref.read(replyProvider.notifier).loadReplies(widget.postId);
    });
  }

  /*
   * 게시글 데이터 로드
   */
  Future<void> _loadPostData() async {
    final post =
        await ref.read(postProvider.notifier).getDetailPost(widget.postId);
    if (post != null) {
      print('*** Loaded Post Data ***');
      print('Posts: ${post} ');
      print('ID: ${post.id}');
      print('Title: ${post.title}');
      print('Content: ${post.content}');
      print('Image URL: ${post.imageUrl}');
      print('************************');
    } else {
      print('Post data is null');
    }

    if (mounted && post != null) {
      setState(() {
        _isPostLoaded = true;
      });
    }
  }

  /*
   * 댓글 전송 처리
   */
  void _onSendReply() async {
    if (_commentController.text.trim().isNotEmpty) {
      final content = _commentController.text.trim();

      try {
        final newReply = Reply(
          id: '',
          author: '',
          authorId: '',
          content: content,
          timeAgo: '',
        );

        await ref
            .read(replyProvider.notifier)
            .createReply(widget.postId, newReply);
        _commentController.clear();

        // 성공 시 포커스 해제
        FocusScope.of(context).unfocus();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 작성 중 오류가 발생했습니다: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 단일 데이터 소스에서 게시글 상태 감시
    final postState = ref.watch(postProvider);
    final replyState = ref.watch(replyProvider);
    final currentPost = postState.findPostById(widget.postId);

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
            onPressed: () => _sharePost(currentPost),
          ),
          if (currentPost != null) _buildMenuButton(currentPost),
        ],
      ),
      body: _buildBody(currentPost, replyState, postState),
    );
  }

  /*
   * 메인 바디 위젯 구성
   */
  Widget _buildBody(
      Post? currentPost, ReplyState replyState, PostState postState) {
    // 로딩 중이거나 게시글이 없는 경우
    if (!_isPostLoaded || currentPost == null) {
      if (postState.error != null) {
        return CommunityErrorWidget(
          error: postState.error!,
          onRetry: _loadPostData,
        );
      }
      return const CommunityLoadingWidget();
    }

    return _buildContent(currentPost, replyState);
  }

  /*
   * 게시글과 댓글을 표시하는 메인 콘텐츠
   */
  Widget _buildContent(Post post, ReplyState replyState) {
    print('=== _buildContent 호출됨 ===');
    print('Post ID: ${post.id}');
    print('Post Title: ${post.title}');
    print('Post Content: ${post.content}');

    return Column(
      children: [
        // 게시글 내용 영역
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 썸네일 이미지 (있는 경우)
                if (post.imageUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Hero(
                      tag: 'postImage-${post.id}',
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.gray200,
                              child: const Icon(Icons.broken_image,
                                  color: AppColors.gray500, size: 50),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                // 게시글 헤더, 본문, 액션 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                      letterSpacing: 0.9,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 3),
                          blurRadius: 2,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12), // 제목과 헤더 사이 간격
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PostDetailHeader(
                    postId: post.id,
                  ),
                ),
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

  /*
   * 게시글 공유 처리
   */
  void _sharePost(Post? post) {
    if (post == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시물 정보를 불러오는 중입니다.')),
      );
      return;
    }

    Share.share(
      '게시물 제목: ${post.title}\n\n내용: ${post.content}',
    );
  }

  /*
   * 메뉴 버튼 (본인 게시글인 경우만)
   */
  Widget _buildMenuButton(Post post) {
    final session = ref.watch(sessionProvider);
    final isMyPost =
        session.isLogin && session.userId.toString() == post.authorId;

    if (!isMyPost) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.more_vert, color: AppColors.white),
      onPressed: () => _showPostMenu(post),
    );
  }

  /*
   * 게시글 수정
   */
  void _editPost(Post post) {
    Navigator.pop(context); // 바텀시트 닫기
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityFormPage(postId: post.id),
      ),
    );
  }

  /*
   * 게시글 삭제
   */
  void _deletePost(Post post) async {
    Navigator.pop(context); // 바텀시트 닫기
    final confirmed = await _showDeleteConfirmDialog();
    if (confirmed) {
      await ref.read(postProvider.notifier).deletePost(post.id);
      if (mounted) {
        Navigator.pop(context); // 상세페이지 닫기
      }
    }
  }

  /*
   * 게시글 메뉴 바텀시트
   */
  void _showPostMenu(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('수정'),
            onTap: () => _editPost(post),
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('삭제', style: TextStyle(color: Colors.red)),
            onTap: () => _deletePost(post),
          ),
        ],
      ),
    );
  }

  /*
   * 삭제 확인 다이얼로그
   */
  Future<bool> _showDeleteConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말로 이 게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
