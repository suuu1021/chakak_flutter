import '../../models/community/post.dart';

class PostDetailDto {
  final String postId;
  final String title;
  final String content;
  final String? imageData;
  final String authorNickname;
  final String authorType;
  final int viewCount;
  final int likeCount;
  final String status;
  final String createdAt;
  final String updatedAt;
  final bool isLiked;
  final bool isOwner;
  final bool hasImage;
  final List<dynamic> replies;

  PostDetailDto({
    required this.postId,
    required this.title,
    required this.content,
    this.imageData,
    required this.authorNickname,
    required this.authorType,
    required this.viewCount,
    required this.likeCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isLiked,
    required this.isOwner,
    required this.hasImage,
    required this.replies,
  });

  factory PostDetailDto.fromJson(Map<String, dynamic> json) {
    print('PostDetailDto.fromJson 실행, 받은 JSON: $json'); // 여기도 로그를 찍어봅니다.

    return PostDetailDto(
      postId: json['postId'].toString(),
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      imageData: json['imageData'] as String?,
      authorNickname: json['authorNickname'] as String? ?? '알 수 없음',
      authorType: json['authorType'] as String? ?? 'user',
      viewCount: json['viewCount'] as int,
      likeCount: json['likeCount'] as int,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isLiked: json['isLiked'] as bool,
      isOwner: json['isOwner'] as bool,
      hasImage: json['hasImage'] as bool,
      replies: json['replies'] as List<dynamic>? ?? [],
    );
  }

  Post toModel() {
    final isAdmin = authorType == 'admin';
    return Post(
      id: postId,
      title: title,
      author: authorNickname,
      authorId: 'unknown', // 서버 응답에 authorId가 없으므로 임의값 설정
      authorBadge: isAdmin ? '✅' : '',
      imageUrl: imageData,
      content: content,
      timeAgo: _formatTimeAgo(createdAt),
      viewCount: viewCount,
      likeCount: likeCount,
      replyCount: replies.length, // 댓글 리스트 길이를 사용
      isAdminPost: isAdmin,
      category: isAdmin ? '공지' : '커뮤니티',
      isActive: status == 'ACTIVE',
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
