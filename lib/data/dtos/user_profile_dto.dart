import '../models/user.dart';
import '../models/user_profile.dart';

class UserProfileDto {
  final int userProfileId;
  final Map<String, dynamic>? user;
  final String nickName;
  final String? introduce;
  final String? imageData;
  final String? createdAt;
  final String? updatedAt;

  UserProfileDto({
    required this.userProfileId,
    this.user,
    required this.nickName,
    this.introduce,
    this.imageData,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      userProfileId: json['userProfileId'] ?? 0,
      user: json['user'] as Map<String, dynamic>?,
      nickName: json['nickName'] ?? '',
      introduce: json['introduce'],
      imageData: json['imageData'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  UserProfile toModel() {
    // user 객체가 없는 경우 기본 User 생성
    User userModel;
    if (user != null && user!.isNotEmpty) {
      userModel = User.fromJson(user!);
    } else {
      // 기본 User 객체 생성 (프로필 조회 시 User 정보가 없는 경우)
      userModel = User(
        userId: 0,
        email: 'unknown@example.com',
        userTypeName: 'user', // userType → userTypeName으로 변경
        status: UserStatus.ACTIVE,
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return UserProfile(
      userProfileId: userProfileId,
      user: userModel,
      nickName: nickName,
      introduce: introduce,
      imageData: imageData,
      createdAt:
          createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      updatedAt:
          updatedAt != null ? DateTime.parse(updatedAt!) : DateTime.now(),
    );
  }
}

class UserProfileCreateRequestDto {
  final int userInfoId;
  final String nickName;
  final String? introduce;
  final String? imageData;

  UserProfileCreateRequestDto({
    required this.userInfoId,
    required this.nickName,
    this.introduce,
    this.imageData,
  });

  Map<String, dynamic> toJson() {
    return {
      'userInfoId': userInfoId,
      'nickName': nickName,
      'introduce': introduce,
      'imageData': imageData,
    };
  }
}

class UserProfileUpdateRequestDto {
  final String nickName;
  final String? introduce;
  final String? imageData;

  UserProfileUpdateRequestDto({
    required this.nickName,
    this.introduce,
    this.imageData,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickName': nickName,
      'introduce': introduce,
      'imageData': imageData,
    };
  }
}
