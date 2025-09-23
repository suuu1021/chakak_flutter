class UserDto {
  final String userId;
  final String email;
  final UserTypeDto userType;

  UserDto({
    required this.userId,
    required this.email,
    required this.userType,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['userId'].toString(),
      email: json['email'] as String,
      userType: UserTypeDto.fromJson(json['userType'] as Map<String, dynamic>),
    );
  }
}

class UserTypeDto {
  final String typeCode;
  final String typeName;

  UserTypeDto({
    required this.typeCode,
    required this.typeName,
  });

  factory UserTypeDto.fromJson(Map<String, dynamic> json) {
    return UserTypeDto(
      typeCode: json['typeCode'] as String,
      typeName: json['typeName'] as String? ?? '알 수 없음',
    );
  }
}
