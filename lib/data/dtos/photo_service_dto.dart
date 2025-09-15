class PhotoServiceDto {
  final int id; // SERVICE_ID
  final int photographerId; // PHOTOGRAPHER_PROFILE_ID
  final String title; // TITLE
  final String description; // DESCRIPTION
  final String imageUrl; // IMAGE_URL
  final List<String> categories; // CATEGORY는 별도 처리 (중간 테이블)
  final int price; // 가격 (별도 테이블에서 가져올 수도 있음)
  final double rating; // 평점 (계산된 값)
  final int reviewCount; // 리뷰 수 (계산된 값)
  final bool isLiked; // 찜 여부 (사용자별)
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
