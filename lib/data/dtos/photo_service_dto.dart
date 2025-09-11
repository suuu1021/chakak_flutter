class PhotoServiceDto {
  final int id;
  final String title;
  final String imageUrl;
  final List<String> categories;
  final int price;
  final double rating;
  final int reviewCount;
  final bool isLiked;

  PhotoServiceDto({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.categories,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.isLiked = false,
  });

  factory PhotoServiceDto.fromJson(Map<String, dynamic> json) {
    return PhotoServiceDto(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      categories: List<String>.from(json['categories'] ?? []),
      price: json['price'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'categories': categories,
      'price': price,
      'rating': rating,
      'review_count': reviewCount,
      'is_liked': isLiked,
    };
  }
}
