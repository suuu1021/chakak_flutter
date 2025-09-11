import '../dtos/photographer_dto.dart';

class Photographer {
  final int id;
  final String businessName;
  final String imageUrl;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final bool isLiked;

  Photographer({
    required this.id,
    required this.businessName,
    required this.imageUrl,
    required this.categories,
    required this.rating,
    required this.reviewCount,
    this.isLiked = false,
  });

  factory Photographer.fromDto(PhotographerDto dto) {
    return Photographer(
      id: dto.id,
      businessName: dto.businessName,
      imageUrl: dto.imageUrl,
      categories: dto.categories,
      rating: dto.rating,
      reviewCount: dto.reviewCount,
      isLiked: dto.isLiked,
    );
  }

  PhotographerDto toDto() {
    return PhotographerDto(
      id: id,
      businessName: businessName,
      imageUrl: imageUrl,
      categories: categories,
      rating: rating,
      reviewCount: reviewCount,
      isLiked: isLiked,
    );
  }

  Photographer copyWith({
    int? id,
    String? businessName,
    String? imageUrl,
    List<String>? categories,
    double? rating,
    int? reviewCount,
    bool? isLiked,
  }) {
    return Photographer(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
