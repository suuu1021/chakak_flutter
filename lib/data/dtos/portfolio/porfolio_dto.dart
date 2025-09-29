import '../../models/portfolio/portfolio.dart';

class PortfolioDto {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final List<String> imageUrls;
  final List<String> categories;
  final int likes;
  final String createdAt;
  final String? updatedAt;
  final String photographerId;
  final String photographerUserId;

  PortfolioDto({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.imageUrls,
    required this.categories,
    required this.likes,
    required this.createdAt,
    this.updatedAt,
    required this.photographerId,
    required this.photographerUserId,
  });

  // 서버 응답 JSON에서 DTO 생성
  factory PortfolioDto.fromJson(Map<String, dynamic> json) {
    return PortfolioDto(
      id: json['portfolioId'].toString(),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      imageUrls: (json['portfolioImages'] as List<dynamic>?)
              ?.map((img) => img['imageUrl'] as String)
              .toList() ??
          [],
      categories: (json['portfolioMaps'] as List<dynamic>?)
              ?.map((map) => map['category']['name'] as String)
              .toList() ??
          [],
      likes: json['likes'] as int? ?? 0,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
      photographerId: json['photographerProfile']['id'].toString(),
      photographerUserId: json['photographerUserId']?.toString() ?? '',
    );
  }

  // Model 객체를 DTO로 변환
  factory PortfolioDto.fromModel(Portfolio model) {
    return PortfolioDto(
      id: model.id,
      title: model.title,
      description: model.description,
      thumbnailUrl: model.thumbnailUrl,
      imageUrls: model.imageUrls,
      categories: model.categories,
      likes: model.likes,
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt?.toIso8601String(),
      photographerId: model.photographerProfileId,
      photographerUserId: model.photographerUserId,
    );
  }

  // DTO를 Model로 변환
  Portfolio toModel() {
    return Portfolio(
      id: id,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      imageUrls: imageUrls,
      categories: categories,
      likes: likes,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      photographerProfileId: photographerId,
      photographerUserId: photographerUserId,
    );
  }
}
