/// 사진작가 프로필 생성/수정 시 사용되는 DTO
class PhotographerProfileFormDto {
  final String businessName;
  final String? introduction;
  final String location;
  final int? experienceYears;
  // final String status; // 제거: 사용자가 직접 상태를 설정하지 않음
  final String? profileImageUrl;
  final List<int>? categoryIds; // 추가: 활동 카테고리 ID 목록

  PhotographerProfileFormDto({
    required this.businessName,
    this.introduction,
    required this.location,
    this.experienceYears,
    // required this.status, // 제거
    this.profileImageUrl,
    this.categoryIds,
  });

  /// DTO를 JSON으로 변환 (서버 요청용)
  /// API 명세에 따라 실제 필드명을 사용해야 합니다.
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

  // fromJson, fromModel, toModel 메소드는 FormDTO의 주 목적(요청 데이터 구성)과
  // 거리가 있으므로 여기서는 제거하거나, 필요 시 응답 DTO 또는 모델 변환 로직은
  // PhotographerProfile 모델 자체 또는 별도의 매퍼 클래스에서 관리하는 것이 좋습니다.
  // 특히 서버 응답을 파싱하는 fromJson은 PhotographerProfile 모델에 이미 구현되어 있습니다.
}
