import '../models/photo_service.dart';

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

  factory PhotoServiceDto.fromModel(PhotoService model) {
    return PhotoServiceDto(
      id: model.id,
      title: model.title,
      imageUrl: model.imageUrl,
      categories: List<String>.from(model.categories),
      price: model.price,
      rating: model.rating,
      reviewCount: model.reviewCount,
      isLiked: model.isLiked,
    );
  }

  // DTO에서 Model로 변환
  PhotoService toModel() {
    return PhotoService(
      id: id,
      title: title,
      imageUrl: imageUrl,
      categories: List<String>.from(categories),
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      isLiked: isLiked,
    );
  }
}
