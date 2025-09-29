class Post {
  final String id;
  final String title;
  final String author;
  final String authorId;
  final String authorBadge;
  final String? imageUrl;
  final String content;
  final String timeAgo;
  final int viewCount;
  final int likeCount;
  final int replyCount;
  final bool isAdminPost;
  final String? category;
  final bool isActive;
  final bool isLiked;

  const Post({
    required this.id,
    required this.title,
    required this.author,
    required this.authorId,
    this.authorBadge = '',
    this.imageUrl,
    required this.content,
    required this.timeAgo,
    this.viewCount = 0,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isAdminPost = false,
    this.category,
    this.isActive = true,
    this.isLiked = false,
  });

  /*
   * 서버로부터 받은 JSON 데이터를 Post 객체로 변환
   */
  factory Post.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final userTypeCode = user?['userType']?['typeCode'] as String?;
    final isAdmin = (userTypeCode == 'admin');

    return Post(
      id: json['postId'].toString(),
      title: json['title'] as String,
      author: user?['username'] as String? ?? '알 수 없음',
      authorId: user?['userId']?.toString() ?? '',
      authorBadge: isAdmin ? '✅' : '',
      imageUrl: json['imageUrl'] as String?,
      content: json['content'] as String,
      timeAgo: json['createdAt'] as String,
      viewCount: json['viewCount'] as int,
      likeCount: json['likeCount'] as int,
      replyCount: json['replyCount'] as int,
      isAdminPost: isAdmin,
      category: isAdmin ? '공지' : '커뮤니티',
      isActive: (json['status'] as String) == 'ACTIVE',
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  /*
   * Post 객체를 JSON 데이터로 변환
   */
  Map<String, dynamic> toJson() {
    return {
      'postId': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
    };
  }

  /*
   * 기존 객체의 일부만 변경하여 새로운 Post 객체를 생성할 때 사용
   */
  Post copyWith({
    String? id,
    String? title,
    String? author,
    String? authorId,
    String? authorBadge,
    String? imageUrl,
    String? content,
    String? timeAgo,
    int? viewCount,
    int? likeCount,
    int? replyCount,
    bool? isAdminPost,
    String? category,
    bool? isActive,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      authorBadge: authorBadge ?? this.authorBadge,
      imageUrl: imageUrl ?? this.imageUrl,
      content: content ?? this.content,
      timeAgo: timeAgo ?? this.timeAgo,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isAdminPost: isAdminPost ?? this.isAdminPost,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
