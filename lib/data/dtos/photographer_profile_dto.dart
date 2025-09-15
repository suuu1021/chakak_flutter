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

  /// 서버 응답 JSON에서 DTO 생성
  factory PhotographerProfileFormDto.fromJson(Map<String, dynamic> json) {
    return PhotographerProfileFormDto(
      id: json['id']?.toString() ?? '',
      businessName: json['businessName'] as String? ?? '',
      introduction: json['introduction'] as String?,
      location: json['location'] as String? ?? '',
      experienceYears: json['experienceYears'] as int?,
      status: json['status'] as String? ?? 'active',
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// 서버 전송용 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'introduction': introduction,
      'location': location,
      'experienceYears': experienceYears,
      'status': status,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Model에서 DTO 생성
  factory PhotographerProfileFormDto.fromModel(PhotographerProfile model) {
    return PhotographerProfileFormDto(
      id: model.id,
      businessName: model.businessName,
      introduction: model.introduction,
      location: model.location,
      experienceYears: model.experienceYears,
      status: model.status,
      profileImageUrl: model.profileImageUrl,
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt?.toIso8601String(),
    );
  }

  /// DTO를 Model로 변환
  PhotographerProfile toModel() {
    return PhotographerProfile(
      id: id,
      businessName: businessName,
      introduction: introduction,
      location: location,
      experienceYears: experienceYears,
      status: status,
      profileImageUrl: profileImageUrl,
      createdAt:
          createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
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
