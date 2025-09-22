import '../../models/community/reply.dart';

class ReplyDto {
  final String replyId;
  final String content;
  final String createdAt;
  final String status;
  final UserDto? user;

  ReplyDto({
    required this.replyId,
    required this.content,
    required this.createdAt,
    required this.status,
    this.user,
  });

  /*
   * 서버로부터 받은 JSON 데이터를 ReplyDto로 변환합니다.
   * 백엔드 PostResponse.ReplyDTO 구조에 맞게 매핑합니다.
   */
  factory ReplyDto.fromJson(Map<String, dynamic> json) {
    return ReplyDto(
      replyId: json['replyId'].toString(),
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      // ReplyDTO에는 status가 없으므로 기본값 'ACTIVE'
      status: 'ACTIVE',
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
      'content': content,
    };
  }

  /*
   * ReplyDto를 앱 내부 모델인 Reply로 변환합니다.
   * 여기서 UI에 필요한 데이터 가공을 수행합니다.
   */
  Reply toModel() {
    final isAdmin = user?.userType?.typeCode == 'admin';

    return Reply(
      id: replyId,
      author: user?.username ?? '알 수 없음',
      authorBadge: isAdmin ? '✅' : '',
      content: content,
      timeAgo: _formatTimeAgo(createdAt),
      isActive: status == 'ACTIVE',
    );
  }

  /*
   * Reply 모델에서 ReplyDto로 변환합니다.
   * 주로 수정 시 사용됩니다.
   */
  static ReplyDto fromModel(Reply reply) {
    return ReplyDto(
      replyId: reply.id,
      content: reply.content,
      createdAt: reply.timeAgo,
      status: reply.isActive ? 'ACTIVE' : 'INACTIVE',
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
