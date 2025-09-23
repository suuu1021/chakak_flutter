import '../models/photographer.dart';

class PhotographerDto {
  final int id;
  final String businessName;
  final String imageUrl;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final bool isLiked;

  PhotographerDto({
    required this.id,
    required this.businessName,
    required this.imageUrl,
    required this.categories,
    required this.rating,
    required this.reviewCount,
    this.isLiked = false,
  });

  factory PhotographerDto.fromJson(Map<String, dynamic> json) {
    return PhotographerDto(
      id: json['photographerId'] as int? ?? 0, // id도 null일 수 있다면 기본값 처리
      businessName: json['businessName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '', // 수정된 부분
      categories: List<String>.from((json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          []), // categories 내부 요소도 String으로 명시적 변환
      rating: (json['averageRating'] as num?)?.toDouble() ??
          0.0, // num?으로 받고 toDouble()
      reviewCount: json['reviewCount'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'imageUrl': imageUrl,
      'categories': categories,
      'rating': rating,
      'review_count': reviewCount,
      'is_liked': isLiked,
    };
  }

  factory PhotographerDto.fromModel(Photographer model) {
    return PhotographerDto(
      id: model.id,
      businessName: model.businessName,
      imageUrl: model.imageUrl,
      categories: List<String>.from(model.categories),
      rating: model.rating,
      reviewCount: model.reviewCount,
      isLiked: model.isLiked,
    );
  }

  // DTO에서 Model로 변환
  Photographer toModel() {
    return Photographer(
      id: id,
      businessName: businessName,
      imageUrl: imageUrl,
      categories: List<String>.from(categories),
      rating: rating,
      reviewCount: reviewCount,
      isLiked: isLiked,
    );
  }
}
