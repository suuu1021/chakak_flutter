//  일반 로그인 요청 DTO
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// 일반 로그인 응답 DTO
class LoginResponse {
  final String tokenType;
  final String accessToken;
  final int userId;
  final String email;
  final String nickname;
  final String userTypeCode; // 명세에 맞춰 필드명 수정 (userType -> userTypeCode)

  LoginResponse({
    required this.tokenType,
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.nickname,
    required this.userTypeCode,
  });

  // JSON 파싱 로직 수정
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      tokenType: json['tokenType'] ?? '',
      accessToken: json['accessToken'] ?? '',
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      userTypeCode: json['userTypeCode'] ?? '', // 명세에 맞춰 키 이름 수정
    );
  }
}

// 소셜 로그인 요청 DTO
class SocialLoginRequest {
  final String code;
  final String typeCode;

  SocialLoginRequest({required this.code, required this.typeCode});

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'typeCode': typeCode,
    };
  }
}

// 소셜 로그인 응답 DTO
class SocialLoginResponse {
  final String jwt;
  final String email;

  SocialLoginResponse({required this.jwt, required this.email});

  factory SocialLoginResponse.fromJson(Map<String, dynamic> json) {
    return SocialLoginResponse(
      jwt: json['jwt'] ?? '', // Null-safe 처리(?? '')
      email: json['email'] ?? '', // 서버에서 값이 누락되더라도 앱이 바로 크래시 나지 않음
    );
  }
}
