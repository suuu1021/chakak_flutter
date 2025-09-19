// <<<     회원가입  요청       >>>
class RegisterRequest {
  final String email;
  final String password;
  final String userTypeCode;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.userTypeCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'userTypeCode': userTypeCode,
    };
  }
}

// <<<    회원가입 응답 DTO     >>>
// 일반 회원가입 성공 응답 DTO
class RegisterResponse {
  final int userId;
  final String email;
  final String userTypeCode;

  RegisterResponse({
    required this.userId,
    required this.email,
    required this.userTypeCode,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['userId'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      userTypeCode: json['userTypeCode'] as String? ?? '',
    );
  }
}

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

class LoginResponse {
  final String tokenType;
  final String accessToken;
  final int userId;
  final String email;
  final String nickname;
  final String userTypeCode;

  LoginResponse({
    required this.tokenType,
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.nickname,
    required this.userTypeCode,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print('LoginResponse 파싱 중: ${json['userTypeCode']}');

    return LoginResponse(
      tokenType: json['tokenType'] ?? '',
      accessToken: json['accessToken'] ?? '',
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      userTypeCode: json['userTypeCode'] ?? '',
    );
  }
}

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

class SocialLoginResponse {
  final String jwt;
  final String email;

  SocialLoginResponse({required this.jwt, required this.email});

  factory SocialLoginResponse.fromJson(Map<String, dynamic> json) {
    return SocialLoginResponse(
      jwt: json['jwt'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
