import 'user.dart';

class UserProfile {
  final int userProfileId;
  final User user;
  final String nickName;
  final String? introduce;
  final String? imageData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.userProfileId,
    required this.user,
    required this.nickName,
    this.introduce,
    this.imageData,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    int? userProfileId,
    User? user,
    String? nickName,
    String? introduce,
    String? imageData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userProfileId: userProfileId ?? this.userProfileId,
      user: user ?? this.user,
      nickName: nickName ?? this.nickName,
      introduce: introduce ?? this.introduce,
      imageData: imageData ?? this.imageData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.userProfileId == userProfileId;
  }

  @override
  int get hashCode => userProfileId.hashCode;

  String get displayName => nickName;
  bool get hasProfileImage => imageData != null && imageData!.isNotEmpty;
  String get formattedIntroduce => introduce ?? '소개글이 없습니다.';

  int get userId => user.userId;
  String get userEmail => user.email;
  String get userTypeName => user.userTypeName;
  UserStatus get userStatus => user.status;
  bool get isEmailVerified => user.emailVerified;
}
