import '../models/photographer_profile.dart';

class PhotographerProfileFormDto {
  final String id;
  final String userId; // 추가된 필드
  final String businessName;
  final String? introduction;
  final String location;
  final int? experienceYears;
  final String status;
  final String? profileImageUrl;
  final String? createdAt;
  final String? updatedAt;
  final List<String> categories;

  PhotographerProfileFormDto({
    required this.id,
    required this.userId, // 추가
    required this.businessName,
    this.introduction,
    required this.location,
    this.experienceYears,
    required this.status,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    required this.categories,
  });

  /// 서버 응답 JSON에서 DTO 생성
  factory PhotographerProfileFormDto.fromJson(Map<String, dynamic> json) {
    // User 객체에서 userId 추출
    String userId = json['userId']?.toString() ?? '';

    final List<String> categories = (json['categories'] as List<dynamic>?)
            ?.map((category) => category as String)
            .toList() ??
        [];

    return PhotographerProfileFormDto(
      id: json['photographerId']?.toString() ?? '',
      userId: userId, // 추가
      businessName: json['businessName'] as String? ?? '',
      introduction: json['introduction'] as String?,
      location: json['location'] as String? ?? '',
      experienceYears: json['experienceYears'] as int?,
      status: json['status'] as String? ?? 'active',
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      categories: categories,
    );
  }

  /// Model에서 DTO 생성
  factory PhotographerProfileFormDto.fromModel(PhotographerProfile model) {
    return PhotographerProfileFormDto(
      id: model.id,
      userId: model.userId, // 추가
      businessName: model.businessName,
      introduction: model.introduction,
      location: model.location,
      experienceYears: model.experienceYears,
      status: model.status,
      profileImageUrl: model.profileImageUrl,
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt?.toIso8601String(),
      categories: model.categories,
    );
  }

  /// DTO를 Model로 변환
  PhotographerProfile toModel() {
    return PhotographerProfile(
      id: id,
      userId: userId, // 추가
      businessName: businessName,
      introduction: introduction,
      location: location,
      experienceYears: experienceYears,
      status: status,
      profileImageUrl: profileImageUrl,
      createdAt:
          createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      categories: categories,
    );
  }
}
