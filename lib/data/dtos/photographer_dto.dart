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
      id: json['id'],
      businessName: json['business_name'],
      imageUrl: json['image_url'],
      categories: List<String>.from(json['categories'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'image_url': imageUrl,
      'categories': categories,
      'rating': rating,
      'review_count': reviewCount,
      'is_liked': isLiked,
    };
  }
}
