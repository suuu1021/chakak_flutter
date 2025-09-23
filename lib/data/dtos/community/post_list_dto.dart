import '../../models/community/post.dart';

class PostListDto {
  final String postId;
  final String title;
  final String content;
  final String authorNickname;
  final String authorId;
  final String authorType;
  final int viewCount;
  final int likeCount;
  final int replyCount;
  final bool hasImage;
  final String? thumbnailData;
  final String createdAt;
  final bool isLiked;

  PostListDto({
    required this.postId,
    required this.title,
    required this.content,
    required this.authorNickname,
    required this.authorId,
    required this.authorType,
    required this.viewCount,
    required this.likeCount,
    required this.replyCount,
    required this.hasImage,
    this.thumbnailData,
    required this.createdAt,
    required this.isLiked,
  });

  factory PostListDto.fromJson(Map<String, dynamic> json) {
    return PostListDto(
      postId: json['postId'].toString(),
      title: json['title'] as String,
      content: json['content'] as String,
      authorNickname: json['authorNickname'] as String? ?? '알 수 없음',
      authorId: json['authorId']?.toString() ?? '',
      authorType: json['authorType'] as String? ?? 'user',
      viewCount: json['viewCount'] as int,
      likeCount: json['likeCount'] as int,
      replyCount: json['replyCount'] as int,
      hasImage: json['hasImage'] as bool,
      thumbnailData: json['thumbnailData'] as String?,
      createdAt: json['createdAt'] as String,
      isLiked: json['liked'] as bool? ?? false,
    );
  }

  Post toModel() {
    final isAdmin = authorType == 'admin';
    return Post(
      id: postId,
      title: title,
      content: content,
      author: authorNickname,
      authorId: authorId,
      authorBadge: isAdmin ? '✅' : '',
      imageUrl: thumbnailData, // 목록에서는 썸네일 데이터를 사용
      timeAgo: _formatTimeAgo(createdAt),
      viewCount: viewCount,
      likeCount: likeCount,
      replyCount: replyCount,
      isAdminPost: isAdmin,
      category: isAdmin ? '공지' : '커뮤니티',
      isActive: true, // 목록에서는 항상 활성 상태로 가정
      isLiked: isLiked,
    );
  }

  String _formatTimeAgo(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}일 전';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}시간 전';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}분 전';
      } else {
        return '방금 전';
      }
    } catch (e) {
      return isoString;
    }
  }
}
