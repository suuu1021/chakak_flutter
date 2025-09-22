import '../../models/community/post.dart';

class PostDto {
  final String postId;
  final String title;
  final String content;
  final String? imageUrl;
  final int viewCount;
  final int likeCount;
  final int replyCount;
  final String createdAt;
  final String status;
  final bool? isLiked;
  final UserDto? user;

  PostDto({
    required this.postId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.viewCount,
    required this.likeCount,
    required this.replyCount,
    required this.createdAt,
    required this.status,
    this.isLiked,
    this.user,
  });

  /*
   * 서버로부터 받은 JSON 데이터를 PostDto로 변환합니다.
   * 백엔드 PostResponse.ListDTO와 PostResponse.DetailDTO 모두 지원합니다.
   */
  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      postId: json['postId'].toString(),
      title: json['title'] as String,
      // ListDTO에는 content가 없고, DetailDTO에는 있음
      content: json['content'] as String? ?? '',
      // ListDTO에서는 thumbnailData, DetailDTO에서는 imageData
      imageUrl: (json['thumbnailData'] ?? json['imageData']) as String?,
      viewCount: json['viewCount'] as int,
      likeCount: json['likeCount'] as int,
      // ListDTO에는 replyCount가 없으므로 기본값 0
      replyCount: json['replyCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String,
      // ListDTO에는 status가 없으므로 기본값 'ACTIVE'
      status: json['status'] as String? ?? 'ACTIVE',
      // 'liked' 필드를 'isLiked'로 매핑
      isLiked: json['liked'] as bool?,
      // 평면적 구조를 UserDto로 변환
      user: UserDto(
        username: json['authorNickname'] as String? ?? '알 수 없음',
        userType:
            UserTypeDto(typeCode: json['authorType'] as String? ?? 'user'),
      ),
    );
  }

  /*
   * 서버로 전송할 JSON 데이터로 변환합니다.
   * 생성/수정 시에만 필요한 필드들만 포함합니다.
   */
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'imageData': imageUrl, // 백엔드는 imageData 필드 사용
    };
  }

  /*
   * PostDto를 앱 내부 모델인 Post로 변환합니다.
   * 여기서 UI에 필요한 데이터 가공을 수행합니다.
   */
  Post toModel() {
    final isAdmin = user?.userType?.typeCode == 'admin';

    return Post(
      id: postId,
      title: title,
      author: user?.username ?? '알 수 없음',
      authorBadge: isAdmin ? '✅' : '',
      imageUrl: imageUrl,
      content: content,
      timeAgo: _formatTimeAgo(createdAt),
      viewCount: viewCount,
      likeCount: likeCount,
      replyCount: replyCount,
      isAdminPost: isAdmin,
      category: isAdmin ? '공지' : '커뮤니티',
      isActive: status == 'ACTIVE',
      isLiked: isLiked ?? false,
    );
  }

  /*
   * Post 모델에서 PostDto로 변환합니다.
   * 주로 수정 시 사용됩니다.
   */
  static PostDto fromModel(Post post) {
    return PostDto(
      postId: post.id,
      title: post.title,
      content: post.content,
      imageUrl: post.imageUrl,
      viewCount: post.viewCount,
      likeCount: post.likeCount,
      replyCount: post.replyCount,
      createdAt: post.timeAgo,
      status: post.isActive ? 'ACTIVE' : 'INACTIVE',
      isLiked: post.isLiked,
    );
  }

  /*
   * ISO 8601 시간을 "n시간 전" 형식으로 변환
   */
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
      return isoString; // 파싱 실패 시 원본 반환
    }
  }
}

/*
 * 사용자 정보를 담는 DTO 클래스
 */
class UserDto {
  final String username;
  final UserTypeDto? userType;

  UserDto({
    required this.username,
    this.userType,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      username: json['username'] as String,
      userType: json['userType'] != null
          ? UserTypeDto.fromJson(json['userType'] as Map<String, dynamic>)
          : null,
    );
  }
}

/*
 * 사용자 타입 정보를 담는 DTO 클래스
 */
class UserTypeDto {
  final String typeCode;

  UserTypeDto({required this.typeCode});

  factory UserTypeDto.fromJson(Map<String, dynamic> json) {
    return UserTypeDto(
      typeCode: json['typeCode'] as String,
    );
  }
}
