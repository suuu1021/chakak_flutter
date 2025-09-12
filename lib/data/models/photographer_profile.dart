import '../dtos/photographer_profile_dto.dart';

class PhotographerProfile {
  final String id;
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
    required this.businessName,
    this.introduction,
    required this.location,
    this.experienceYears,
    required this.status,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// DTO에서 Model 생성
  factory PhotographerProfile.fromDto(PhotographerProfileFormDto dto) {
    return PhotographerProfile(
      id: dto.id,
      businessName: dto.businessName,
      introduction: dto.introduction,
      location: dto.location,
      experienceYears: dto.experienceYears,
      status: dto.status,
      profileImageUrl: dto.profileImageUrl,
      createdAt: dto.createdAt != null
          ? DateTime.parse(dto.createdAt!)
          : DateTime.now(),
      updatedAt: dto.updatedAt != null ? DateTime.parse(dto.updatedAt!) : null,
    );
  }

  /// Model을 DTO로 변환
  PhotographerProfileFormDto toDto() {
    return PhotographerProfileFormDto(
      id: id,
      businessName: businessName,
      introduction: introduction,
      location: location,
      experienceYears: experienceYears,
      status: status,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt?.toIso8601String(),
    );
  }

  /// copyWith 메서드 (불변성 유지)
  PhotographerProfile copyWith({
    String? id,
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
      businessName: '',
      location: '',
      status: '활성',
      createdAt: DateTime.now(),
    );
  }

  /// 화면 표시용 상태
  String get displayStatus {
    switch (status) {
      case 'active':
        return '활성';
      case 'inactive':
        return '비활성';
      default:
        return status; // 이미 한국어면 그대로
    }
  }

  /// API 전송용 상태
  String get apiStatus {
    switch (status) {
      case '활성':
        return 'active';
      case '비활성':
        return 'inactive';
      default:
        return status; // 이미 영어면 그대로
    }
  }

  /// 프로필 완성도 체크
  bool get isComplete {
    return businessName.trim().isNotEmpty &&
        location.trim().isNotEmpty &&
        introduction?.trim().isNotEmpty == true &&
        profileImageUrl?.isNotEmpty == true;
  }

  /// 활성 상태인지 체크
  bool get isActive {
    return status == '활성' || status == 'active';
  }

  /// 경력 표시 텍스트
  String get experienceText {
    if (experienceYears == null || experienceYears == 0) {
      return '신입';
    }
    return '${experienceYears}년';
  }

  /// 프로필 요약 정보 (리스트 표시용)
  String get summary {
    final parts = <String>[
      location,
      experienceText,
    ];

    return parts.join(' • ');
  }

  /// 소개글 미리보기 (최대 50자)
  String get introductionPreview {
    if (introduction == null || introduction!.isEmpty) {
      return '소개글이 없습니다';
    }

    if (introduction!.length <= 50) {
      return introduction!;
    }

    return '${introduction!.substring(0, 50)}...';
  }

  /// 프로필 이미지 URL (기본 이미지 포함)
  String get displayImageUrl {
    return profileImageUrl ?? 'assets/images/default_profile.png';
  }

  /// 검색용 키워드 생성
  List<String> get searchKeywords {
    final keywords = <String>[
      businessName.toLowerCase(),
      location.toLowerCase(),
    ];

    if (introduction != null) {
      keywords.addAll(introduction!
          .toLowerCase()
          .split(' ')
          .where((word) => word.length > 1));
    }

    return keywords.toSet().toList(); // 중복 제거
  }

  /// JSON 직렬화를 위한 Map 변환 (로컬 저장용)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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

  /// Map에서 Model 생성 (로컬 저장에서 복원)
  factory PhotographerProfile.fromMap(Map<String, dynamic> map) {
    return PhotographerProfile(
      id: map['id'] as String,
      businessName: map['businessName'] as String,
      introduction: map['introduction'] as String?,
      location: map['location'] as String,
      experienceYears: map['experienceYears'] as int?,
      status: map['status'] as String,
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'PhotographerProfile('
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
    return other is PhotographerProfile &&
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
