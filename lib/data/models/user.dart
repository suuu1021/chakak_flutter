enum UserStatus {
  ACTIVE, // 활성
  INACTIVE, // 비활성
  PENDING, // 대기 중
  SUSPENDED; // 정지됨

  static UserStatus fromString(String? statusString) {
    if (statusString == null) {
      throw ArgumentError(
          'UserStatus 문자열은 null일 수 없습니다. 지원되는 값: ${UserStatus.values.map((s) => s.name).join(',')}');
    }
    try {
      return UserStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == statusString.toUpperCase(),
      );
    } catch (e) {
      throw ArgumentError(
          '알 수 없는 UserStatus 문자열입니다: "$statusString". 지원되는 값: ${UserStatus.values.map((s) => s.name).join(',')}');
    }
  }
}

class User {
  final int userId;
  final String email;
  final String userTypeName;
  final UserStatus status;
  final bool emailVerified;
  final String? provider;
  final String? providerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.userId,
    required this.email,
    required this.userTypeName,
    required this.status,
    required this.emailVerified,
    this.provider,
    this.providerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? statusStringFromJson = json['status'] as String?;
    UserStatus statusValue;

    try {
      if (statusStringFromJson == null) {
        statusValue = UserStatus.INACTIVE;
      } else {
        statusValue = UserStatus.fromString(statusStringFromJson);
      }
    } catch (e) {
      statusValue = UserStatus.INACTIVE;
    }

    return User(
      userId: json['userId'] as int? ?? json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      userTypeName: json['userTypeName'] as String? ??
          json['userTypeCode'] as String? ??
          'UNKNOWN',
      status: statusValue,
      emailVerified: json['emailVerified'] as bool? ?? false,
      provider: json['provider'] as String?,
      providerId: json['providerId'] as String?,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'userTypeName': userTypeName,
      'status': status.name,
      'emailVerified': emailVerified,
      'provider': provider,
      'providerId': providerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    int? userId,
    String? email,
    String? userTypeName,
    UserStatus? status,
    bool? emailVerified,
    String? provider,
    String? providerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      userTypeName: userTypeName ?? this.userTypeName,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      provider: provider ?? this.provider,
      providerId: providerId ?? this.providerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, userTypeName: $userTypeName, status: $status, emailVerified: $emailVerified, provider: $provider, providerId: $providerId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
