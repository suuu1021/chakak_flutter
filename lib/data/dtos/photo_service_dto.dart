import '../models/photo_service/price_option.dart';

class PhotoServiceDto {
  final int id; // SERVICE_ID
  final int photographerId; // PHOTOGRAPHER_PROFILE_ID
  final String title; // TITLE
  final String description; // DESCRIPTION
  final String imageUrl; // IMAGE_URL
  final List<String> categories; // CATEGORY는 별도 처리 (중간 테이블)
  final int price; // 기본 가격 (별도 테이블에서 가져올 수도 있음)
  final double rating; // 평점 (계산된 값)
  final int reviewCount; // 리뷰 수 (계산된 값)
  final bool isLiked; // 찜 여부 (사용자별)
  final List<PriceOptionDto> priceOptions; // 가격 옵션들 (별도 테이블)
  final List<String> portfolioImages; // 포트폴리오 이미지 URL들
  final DateTime createdAt; // CREATED_AT
  final DateTime updatedAt; // UPDATED_AT

  PhotoServiceDto({
    required this.id,
    required this.photographerId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.categories,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.isLiked = false,
    this.priceOptions = const [],
    this.portfolioImages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory PhotoServiceDto.fromJson(Map<String, dynamic> json) {
    return PhotoServiceDto(
      id: json['id'] ?? json['SERVICE_ID'] ?? 0,
      photographerId:
          json['photographerId'] ?? json['PHOTOGRAPHER_PROFILE_ID'] ?? 0,
      title: json['title'] ?? json['TITLE'] ?? '',
      description: json['description'] ?? json['DESCRIPTION'] ?? '',
      imageUrl: json['imageUrl'] ?? json['IMAGE_URL'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      price: json['price'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      priceOptions: (json['priceOptions'] as List<dynamic>?)
              ?.map((item) =>
                  PriceOptionDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['CREATED_AT'] != null
              ? DateTime.parse(json['CREATED_AT'])
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['UPDATED_AT'] != null
              ? DateTime.parse(json['UPDATED_AT'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photographerId': photographerId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'categories': categories,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'isLiked': isLiked,
      'priceOptions': priceOptions.map((option) => option.toJson()).toList(),
      'portfolioImages': portfolioImages,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PhotoServiceDto copyWith({
    int? id,
    int? photographerId,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? categories,
    int? price,
    double? rating,
    int? reviewCount,
    bool? isLiked,
    List<PriceOptionDto>? priceOptions,
    List<String>? portfolioImages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotoServiceDto(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isLiked: isLiked ?? this.isLiked,
      priceOptions: priceOptions ?? this.priceOptions,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// PriceOption의 DTO 버전
class PriceOptionDto {
  final String name;
  final int price;
  final String duration;
  final String photoCount;
  final String editingLevel;
  final List<String> features;

  const PriceOptionDto({
    required this.name,
    required this.price,
    required this.duration,
    required this.photoCount,
    required this.editingLevel,
    required this.features,
  });

  factory PriceOptionDto.fromJson(Map<String, dynamic> json) {
    return PriceOptionDto(
      name: json['name'] as String,
      price: json['price'] as int,
      duration: json['duration'] as String,
      photoCount: json['photoCount'] as String,
      editingLevel: json['editingLevel'] as String,
      features: List<String>.from(json['features'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'photoCount': photoCount,
      'editingLevel': editingLevel,
      'features': features,
    };
  }

  // DTO에서 Model로 변환
  PriceOption toModel() {
    return PriceOption(
      name: name,
      price: price,
      duration: duration,
      photoCount: photoCount,
      editingLevel: editingLevel,
      features: features,
    );
  }
}
