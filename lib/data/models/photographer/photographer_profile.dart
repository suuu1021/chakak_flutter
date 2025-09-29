import 'photographer_category.dart';

class PhotographerProfile {
  final String id;
  final String userId;
  final String businessName;
  final String? introduction;
  final String location;
  final int? experienceYears;
  final String status;
  final String? profileImageUrl;
  final List<PhotographerCategory>? categories;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PhotographerProfile({
    required this.id,
    required this.userId,
    required this.businessName,
    this.introduction,
    required this.location,
    this.experienceYears,
    required this.status,
    this.profileImageUrl,
    this.categories,
    required this.createdAt,
    this.updatedAt,
  });

  factory PhotographerProfile.fromJson(Map<String, dynamic> json) {
    final dynamic rawId =
        json['photographerProfileId'] ?? json['photographerId'] ?? json['id'];
    if (rawId == null) {
      throw FormatException('프로필 ID가 없습니다.');
    }
    final String id = rawId.toString();

    final String? businessNameRaw =
        json['businessName'] ?? json['business_name'];
    final String? locationRaw =
        json['location'] ?? json['addr'] ?? json['region'];

    if (businessNameRaw == null || locationRaw == null) {
      throw FormatException('필수 프로필 정보(businessName 또는 location)가 누락되었습니다.');
    }

    final String businessName = businessNameRaw.toString();
    final String location = locationRaw.toString();

    String userId = '';
    if (json['userId'] != null) {
      userId = json['userId'].toString();
    } else if (json['user'] != null) {
      final userObj = json['user'];
      if (userObj is Map &&
          (userObj['id'] != null || userObj['userId'] != null)) {
        userId = (userObj['id'] ?? userObj['userId']).toString();
      }
    }

    int? experienceYears;
    try {
      if (json['experienceYears'] != null) {
        experienceYears = (json['experienceYears'] is int)
            ? json['experienceYears'] as int
            : int.tryParse(json['experienceYears'].toString());
      }
    } catch (_) {
      experienceYears = null;
    }

    final String status =
        (json['status'] as String?)?.toLowerCase() ?? 'active';
    final String? profileImageUrl =
        json['profileImageUrl'] as String? ?? json['imageUrl'] as String?;

    List<PhotographerCategory>? categoriesList;
    if (json['categories'] != null && json['categories'] is List) {
      categoriesList = (json['categories'] as List)
          .map((categoryJson) => PhotographerCategory.fromJson(
              categoryJson as Map<String, dynamic>))
          .toList();
    } else if (json['categoryList'] != null && json['categoryList'] is List) {
      categoriesList = (json['categoryList'] as List)
          .map((categoryJson) => PhotographerCategory.fromJson(
              categoryJson as Map<String, dynamic>))
          .toList();
    } else if (json['photographerCategories'] != null &&
        json['photographerCategories'] is List) {
      // Another common key
      categoriesList = (json['photographerCategories'] as List)
          .map((categoryJson) => PhotographerCategory.fromJson(
              categoryJson as Map<String, dynamic>))
          .toList();
    }

    DateTime createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt'] as String);
      } catch (_) {
        createdAt = DateTime.now();
      }
    } else if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at'] as String);
      } catch (_) {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(json['updatedAt'] as String);
      } catch (_) {
        updatedAt = null;
      }
    } else if (json['updated_at'] != null) {
      try {
        updatedAt = DateTime.parse(json['updated_at'] as String);
      } catch (_) {
        updatedAt = null;
      }
    }

    return PhotographerProfile(
      id: id,
      userId: userId,
      businessName: businessName,
      introduction: json['introduction'] as String?,
      location: location,
      experienceYears: experienceYears,
      status: status,
      profileImageUrl: profileImageUrl,
      categories: categoriesList,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photographerProfileId': id,
      'userId': userId,
      'businessName': businessName,
      'introduction': introduction,
      'location': location,
      'experienceYears': experienceYears,
      'status': status,
      'profileImageUrl': profileImageUrl,
      'categories': categories?.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PhotographerProfile copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? introduction,
    String? location,
    int? experienceYears,
    String? status,
    String? profileImageUrl,
    List<PhotographerCategory>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotographerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      introduction: introduction ?? this.introduction,
      location: location ?? this.location,
      experienceYears: experienceYears ?? this.experienceYears,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PhotographerProfile.empty() {
    return PhotographerProfile(
      id: '',
      userId: '',
      businessName: '',
      location: '',
      status: 'active',
      categories: [],
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PhotographerProfile('
        'id: $id, '
        'userId: $userId, '
        'businessName: $businessName, '
        'introduction: $introduction, '
        'location: $location, '
        'experienceYears: $experienceYears, '
        'status: $status, '
        'profileImageUrl: $profileImageUrl, '
        'categories: $categories, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotographerProfile &&
        other.id == id &&
        other.userId == userId &&
        other.businessName == businessName &&
        other.introduction == introduction &&
        other.location == location &&
        other.experienceYears == experienceYears &&
        other.status == status &&
        other.profileImageUrl == profileImageUrl &&
        other.categories == categories &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      businessName,
      introduction,
      location,
      experienceYears,
      status,
      profileImageUrl,
      categories,
      createdAt,
      updatedAt,
    );
  }
}
