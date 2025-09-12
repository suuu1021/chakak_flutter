import '../models/photographer_profile.dart';

class PhotographerProfileFormDto {
  final String id;
  final String businessName;
  final String? introduction;
  final String location;
  final int? experienceYears;
  final String status;
  final String? profileImageUrl;
  final String? createdAt;
  final String? updatedAt;

  PhotographerProfileFormDto({
    required this.id,
    required this.businessName,
    this.introduction,
    required this.location,
    this.experienceYears,
    required this.status,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  // 서버 응답 JSON에서 DTO 생성 (서버 구조에 맞춤)
  factory PhotographerProfileFormDto.fromJson(Map<String, dynamic> json) {
    return PhotographerProfileFormDto(
      id: json['id'].toString(),
      businessName: json['businessName'] as String,
      introduction: json['introduction'] as String?,
      location: json['location'] as String,
      experienceYears: json['experienceYears'] as int?,
      status: json['status'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  // 서버 전송용 JSON 변환 (서버가 기대하는 구조)
  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'introduction': introduction,
      'location': location,
      'experienceYears': experienceYears,
      'status': _convertToApiStatus(status),
      'profileImageUrl': profileImageUrl,
    };
  }

  // 포트폴리오 생성용 요청 DTO (간소화된 버전)
  Map<String, dynamic> toCreateRequest() {
    return {
      'businessName': businessName,
      'introduction': introduction,
      'location': location,
      'experienceYears': experienceYears,
      'status': _convertToApiStatus(status),
      'profileImageUrl': profileImageUrl,
    };
  }

  // 포트폴리오 수정용 요청 DTO
  Map<String, dynamic> toUpdateRequest() {
    return {
      'businessName': businessName,
      'introduction': introduction,
      'location': location,
      'experienceYears': experienceYears,
      'status': _convertToApiStatus(status),
      'profileImageUrl': profileImageUrl,
    };
  }

  // 폼 데이터에서 DTO 생성 (새로 생성 시 사용)
  factory PhotographerProfileFormDto.fromFormData({
    required String businessName,
    String? introduction,
    required String location,
    int? experienceYears,
    required String displayStatus, // '활성', '비활성'
    String? profileImageUrl,
  }) {
    return PhotographerProfileFormDto(
      id: '', // 새 생성 시에는 빈 값
      businessName: businessName.trim(),
      introduction:
          introduction?.trim().isNotEmpty == true ? introduction!.trim() : null,
      location: location.trim(),
      experienceYears: experienceYears,
      status: displayStatus,
      profileImageUrl: profileImageUrl,
    );
  }

  // 기존 DTO에서 폼 데이터로 수정하여 새 DTO 생성 (수정 시 사용)
  PhotographerProfileFormDto updateFromFormData({
    String? businessName,
    String? introduction,
    String? location,
    int? experienceYears,
    String? displayStatus,
    String? profileImageUrl,
  }) {
    return PhotographerProfileFormDto(
      id: id,
      businessName: (businessName ?? this.businessName).trim(),
      introduction: introduction?.trim().isNotEmpty == true
          ? introduction!.trim()
          : this.introduction,
      location: (location ?? this.location).trim(),
      experienceYears: experienceYears ?? this.experienceYears,
      status: displayStatus ?? status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // 화면 표시용 상태 변환
  String get displayStatus => _convertToDisplayStatus(status);

  // 유효성 검사
  bool get isValid {
    return businessName.trim().isNotEmpty &&
        location.trim().isNotEmpty &&
        _isValidStatus(status) &&
        _isValidExperienceYears(experienceYears);
  }

  // 필드별 유효성 검사 메서드들
  bool _isValidStatus(String status) {
    return ['활성', '비활성', 'active', 'inactive'].contains(status);
  }

  bool _isValidExperienceYears(int? years) {
    if (years == null) return true;
    return years >= 0 && years <= 50;
  }

  // 화면 상태 → API 상태 변환
  String _convertToApiStatus(String displayStatus) {
    switch (displayStatus) {
      case '활성':
        return 'active';
      case '비활성':
        return 'inactive';
      case 'active':
      case 'inactive':
        return displayStatus; // 이미 API 형태면 그대로
      default:
        return 'active'; // 기본값
    }
  }

  // API 상태 → 화면 상태 변환
  String _convertToDisplayStatus(String apiStatus) {
    switch (apiStatus) {
      case 'active':
        return '활성';
      case 'inactive':
        return '비활성';
      case '활성':
      case '비활성':
        return apiStatus; // 이미 화면 형태면 그대로
      default:
        return '활성'; // 기본값
    }
  }

  @override
  String toString() {
    return 'PhotographerProfileFormDto('
        'id: $id, '
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
    return other is PhotographerProfileFormDto &&
        other.id == id &&
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
