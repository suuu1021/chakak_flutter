class PhotographerProfile {
  final String id;
  final String userId; // 추가: 실제 User ID
  final String businessName;
  final String? introduction;
  final String location;
  final int? experienceYears;
  final String status;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PhotographerProfile({
    required this.id,
    required this.userId, // 추가
    required this.businessName,
    this.introduction,
    required this.location,
    this.experienceYears,
    required this.status,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON에서 Model 생성 (서버 통신용)
  factory PhotographerProfile.fromJson(Map<String, dynamic> json) {
    // 필수 필드가 없을 경우 예외 발생
    if (json['photographerProfileId'] == null ||
        json['businessName'] == null ||
        json['location'] == null) {
      throw FormatException('필수 프로필 정보가 누락되었습니다.');
    }

    // 데이터 타입 안전성 확보
    final String id = json['photographerProfileId'].toString();
    final String businessName = json['businessName'] as String;
    final String location = json['location'] as String;

    // User 객체에서 userId 추출
    String userId;
    if (json['user'] != null && json['user']['id'] != null) {
      userId = json['user']['id'].toString();
    } else {
      throw FormatException('User 정보가 누락되었습니다.');
    }

    return PhotographerProfile(
      id: id,
      userId: userId, // 추가
      businessName: businessName,
      introduction: json['introduction'] as String?,
      location: location,
      experienceYears: json['experienceYears'] as int?,
      status: json['status'] as String? ?? 'active',
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Model을 JSON으로 변환 (서버 통신용)
  Map<String, dynamic> toJson() {
    return {
      'photographerProfileId': id,
      'businessName': businessName,
      'introduction': introduction,
      'location': location,
      'experienceYears': experienceYears,
      'status': status,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// copyWith 메서드 (불변성 유지)
  PhotographerProfile copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? introduction,
    String? location,
    int? experienceYears,
    String? status,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotographerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId, // 추가
      businessName: businessName ?? this.businessName,
      introduction: introduction ?? this.introduction,
      location: location ?? this.location,
      experienceYears: experienceYears ?? this.experienceYears,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 빈 프로필 생성 (초기값용)
  factory PhotographerProfile.empty() {
    return PhotographerProfile(
      id: '',
      userId: '', // 추가
      businessName: '',
      location: '',
      status: 'active',
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PhotographerProfile('
        'id: $id, '
        'userId: $userId, ' // 추가
        'businessName: $businessName, '
        'introduction: $introduction, '
        'location: $location, '
        'experienceYears: $experienceYears, '
        'status: $status, '
        'profileImageUrl: $profileImageUrl, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotographerProfile &&
        other.id == id &&
        other.userId == userId && // 추가
        other.businessName == businessName &&
        other.introduction == introduction &&
        other.location == location &&
        other.experienceYears == experienceYears &&
        other.status == status &&
        other.profileImageUrl == profileImageUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId, // 추가
      businessName,
      introduction,
      location,
      experienceYears,
      status,
      profileImageUrl,
      createdAt,
      updatedAt,
    );
  }
}
