import '../dtos/photo_service_dto.dart';

class PhotoService {
  final int id;
  final String title;
  final String imageUrl;
  final List<String> categories;
  final int price;
  final double rating;
  final int reviewCount;
  final bool isLiked;

  PhotoService({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.categories,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.isLiked = false,
  });

  factory PhotoService.fromDto(PhotoServiceDto dto) {
    return PhotoService(
      id: dto.id,
      title: dto.title,
      imageUrl: dto.imageUrl,
      categories: dto.categories,
      price: dto.price,
      rating: dto.rating,
      reviewCount: dto.reviewCount,
      isLiked: dto.isLiked,
    );
  }

  PhotoServiceDto toDto() {
    return PhotoServiceDto(
      id: id,
      title: title,
      imageUrl: imageUrl,
      categories: categories,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      isLiked: isLiked,
    );
  }

  PhotoService copyWith({
    int? id,
    String? title,
    String? imageUrl,
    List<String>? categories,
    int? price,
    double? rating,
    int? reviewCount,
    bool? isLiked,
  }) {
    return PhotoService(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
