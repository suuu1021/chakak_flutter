import 'package:flutter/material.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../data/models/community/reply.dart';
import '../../../../provider/community/reply_provider.dart';

/*
 * 댓글 섹션과 개별 댓글 아이템을 관리하는 위젯
 * 댓글 목록 표시와 댓글 상호작용을 담당
 */
class ReplySection extends StatelessWidget {
  final ReplyState replyState;

  const ReplySection({
    super.key,
    required this.replyState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '댓글 ${replyState.replies.length}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // 댓글 로딩/에러 상태
          if (replyState.isLoading && replyState.replies.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          if (replyState.error != null && replyState.replies.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '댓글을 불러올 수 없습니다: ${replyState.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          // 댓글 리스트
          if (replyState.replies.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: replyState.replies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final reply = replyState.replies[index];
                return ReplyItem(reply: reply);
              },
            ),
        ],
      ),
    );
  }
}

/*
 * 개별 댓글 아이템 위젯
 * 댓글의 작성자, 내용, 좋아요 기능을 표시
 */
class ReplyItem extends StatefulWidget {
  final Reply reply;

  const ReplyItem({super.key, required this.reply});

  @override
  State<ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<ReplyItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    widget.reply.author,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.reply.authorBadge.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      widget.reply.authorBadge,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Text(
                    widget.reply.timeAgo,
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
                widget.reply.content,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
