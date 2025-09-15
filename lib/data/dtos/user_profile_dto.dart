import '../models/user.dart';
import '../models/user_profile.dart';

class UserProfileDto {
  final int userProfileId;
  final Map<String, dynamic> user;
  final String nickName;
  final String? introduce;
  final String? imageData;
  final String createdAt;
  final String updatedAt;

  UserProfileDto({
    required this.userProfileId,
    required this.user,
    required this.nickName,
    this.introduce,
    this.imageData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      userProfileId: json['userProfileId'] ?? 0,
      user: json['user'] ?? {},
      nickName: json['nickName'] ?? '',
      introduce: json['introduce'],
      imageData: json['imageData'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  UserProfile toModel() {
    return UserProfile(
      userProfileId: userProfileId,
      user: User.fromJson(user),
      nickName: nickName,
      introduce: introduce,
      imageData: imageData,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
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
