class PhotographerProfileFormDto {
  final String businessName;
  final String? introduction;
  final String location;
  final int? experienceYears;
  final String? profileImageUrl;
  final List<int>? categoryIds;

  PhotographerProfileFormDto({
    required this.businessName,
    this.introduction,
    required this.location,
    this.experienceYears,
    this.profileImageUrl,
    this.categoryIds,
  });

  // DTO를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'introduction': introduction,
      'location': location,
      'experienceYears': experienceYears,
      'profileImageUrl': profileImageUrl,
      'categoryIds': categoryIds,
    };
  }
}
