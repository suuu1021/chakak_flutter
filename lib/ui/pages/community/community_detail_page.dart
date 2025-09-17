import 'package:flutter/material.dart';

import '../../../_core/constants/app_colors.dart';
import 'commmunity_list_page.dart';

// 댓글 모델
class Comment {
  final String id;
  final String author;
  final String authorBadge;
  final String content;
  final String timeAgo;
  final int likes;
  final bool isLiked;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.author,
    this.authorBadge = '',
    required this.content,
    required this.timeAgo,
    this.likes = 0,
    this.isLiked = false,
    this.replies = const [],
  });
}

class CommunityDetailPage extends StatefulWidget {
  final Post post;

  const CommunityDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  static const String adminBadge = '✅';
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;
  bool isBookmarked = false;
  int likeCount = 127;

  // 더미 댓글 데이터
  final List<Comment> dummyComments = [
    Comment(
      id: '1',
      author: '포토마니아',
      content: '정말 유용한 정보네요! 감사합니다 ㅎㅎ 덕분에 좋은 작가님 찾을 수 있을 것 같아요',
      timeAgo: '2시간 전',
      likes: 12,
      isLiked: false,
    ),
    Comment(
      id: '2',
      author: '스냅초보',
      content: '혹시 신촌 쪽에서 촬영 가능한 작가님도 있나요?',
      timeAgo: '4시간 전',
      likes: 3,
      isLiked: true,
      replies: [
        Comment(
          id: '2-1',
          author: '찰칵관리팀',
          authorBadge: adminBadge,
          content: '신촌 지역 작가님들도 많이 계세요! DM으로 상세 정보 보내드릴게요',
          timeAgo: '3시간 전',
          likes: 8,
        ),
      ],
    ),
    Comment(
      id: '3',
      author: '웨딩스냅러버',
      content: '작가님들 포트폴리오가 정말 다양하네요! 특히 야외 촬영 전문가분들이 많아서 좋아요',
      timeAgo: '6시간 전',
      likes: 15,
    ),
    Comment(
      id: '4',
      author: '졸사준비생',
      content: '졸업사진 찍으려고 하는데 추천해주신 작가님 중에 학생 할인 되는 분 계실까요?',
      timeAgo: '8시간 전',
      likes: 7,
      replies: [
        Comment(
          id: '4-1',
          author: '캠퍼스걸',
          content: '저도 궁금해요! 학생증 지참하면 할인 되는 곳 있으면 좋겠네요',
          timeAgo: '7시간 전',
          likes: 2,
        ),
      ],
    ),
    Comment(
      id: '5',
      author: '커플스냅',
      content: '이번 주말에 촬영 예정인데 날씨가 걱정이네요 ㅠㅠ',
      timeAgo: '10시간 전',
      likes: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 게시글 내용 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 게시글 헤더
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카테고리 태그
                        if (widget.post.category.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.post.category,
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
                  ),

                  // 게시글 본문
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '안녕하세요! 찰칵 관리팀입니다.\n\n이번에 새롭게 업데이트된 스냅촬영 작가님 추천 리스트를 공지드립니다.\n\n✨ 엄선된 프로 작가님들만 모았어요!\n• 포트폴리오 검증 완료\n• 고객 만족도 95% 이상\n• 다양한 컨셉과 스타일 보유\n\n📍 지역별 추천 작가님\n• 강남/서초: 10명\n• 홍대/신촌: 8명  \n• 성수/건대: 6명\n• 기타 지역: 12명\n\n💡 촬영 팁\n1. 사전 상담을 통해 원하는 컨셉 공유\n2. 날씨와 시간대 고려한 스케줄링\n3. 의상과 소품 미리 준비\n\n궁금한 점이 있으시면 언제든 문의해주세요!\n\n감사합니다. 😊',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 좋아요/북마크 버튼
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                            setState(() {
                              isLiked = !isLiked;
                              if (isLiked) {
                                likeCount++;
                              } else {
                                likeCount--;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isLiked
                                  ? AppColors.primary
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  color: isLiked
                                      ? AppColors.white
                                      : AppColors.gray600,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  likeCount.toString(),
                                  style: TextStyle(
                                    color: isLiked
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
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isBookmarked
                                  ? AppColors.secondary
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                  color: isBookmarked
                                      ? AppColors.white
                                      : AppColors.gray600,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '북마크',
                                  style: TextStyle(
                                    color: isBookmarked
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
                      ],
                    ),
                  ),

                  // 댓글 섹션
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '댓글 ${dummyComments.length + dummyComments.fold(0, (sum, comment) => sum + comment.replies.length)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 댓글 리스트
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dummyComments.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final comment = dummyComments[index];
                            return CommentItem(comment: comment);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 댓글 입력 영역
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send,
                        color: AppColors.white, size: 20),
                    onPressed: () {
                      if (_commentController.text.trim().isNotEmpty) {
                        // 댓글 등록 로직
                        _commentController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class CommentItem extends StatefulWidget {
  final Comment comment;

  const CommentItem({super.key, required this.comment});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool isLiked = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.comment.isLiked;
    likeCount = widget.comment.likes;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인 댓글
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.gray200,
              child: const Icon(
                Icons.person,
                color: AppColors.gray500,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 작성자 정보
                  Row(
                    children: [
                      Text(
                        widget.comment.author,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.comment.authorBadge.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          widget.comment.authorBadge,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        widget.comment.timeAgo,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 댓글 내용
                  Text(
                    widget.comment.content,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 좋아요 버튼
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                        if (isLiked) {
                          likeCount++;
                        } else {
                          likeCount--;
                        }
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color:
                              isLiked ? AppColors.primary : AppColors.gray500,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          likeCount.toString(),
                          style: TextStyle(
                            color:
                                isLiked ? AppColors.primary : AppColors.gray500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '답글',
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // 답글들
        if (widget.comment.replies.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: widget.comment.replies.map((reply) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CommentItem(comment: reply),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
