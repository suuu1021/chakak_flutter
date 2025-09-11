import '../models/portfolio.dart';

class PortfolioDto {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final int likes;
  final String createdAt;

  PortfolioDto({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.likes,
    required this.createdAt,
  });

  // JSON에서 Map 구조로 변환한 뒤 map 구조에서 DTO 클래스를 생성하는 코드
  factory PortfolioDto.fromJson(Map<String, dynamic> json) {
    return PortfolioDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      likes: json['likes'] as int,
      createdAt: json['createdAt'] as String,
    );
  }

  // DTO 객체를 JSON으로 변환시 사용 (서버 전송용)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'likes': likes,
      'createdAt': createdAt,
    };
  }

  // Model 객체를 DTO로 변환하는 기능
  factory PortfolioDto.fromModel(Portfolio model) {
    return PortfolioDto(
      id: model.id,
      title: model.title,
      description: model.description,
      category: model.category,
      imageUrl: model.imageUrl,
      likes: model.likes,
      createdAt: model.createdAt.toIso8601String(),
    );
  }

  // PortfolioDto > Portfolio class construct
  // PortfolioDto.toModel(); > Portfolio() construct
  Portfolio toModel() {
    return Portfolio(
      id: id,
      title: title,
      description: description,
      category: category,
      imageUrl: imageUrl,
      likes: likes,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
