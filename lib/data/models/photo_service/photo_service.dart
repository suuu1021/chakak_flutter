// data/models/photo_service.dart

import '../../dtos/photo_service_dto.dart';
import 'price_option.dart';

class PhotoService {
  final int id;
  final int photographerId;
  final String title;
  final String imageUrl;
  final List<String> categories;
  final int price; // 기본 가격 (최저가 표시용)
  final double rating;
  final int reviewCount;
  final bool isLiked;
  final String description; // 서비스 설명
  final List<PriceOption> priceOptions; // 가격 옵션들
  final List<String> portfolioImages; // 포트폴리오 이미지들

  PhotoService({
    required this.id,
    required this.photographerId,
    required this.title,
    required this.imageUrl,
    required this.categories,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.isLiked = false,
    this.description = '',
    this.priceOptions = const [],
    this.portfolioImages = const [],
  });

  factory PhotoService.fromDto(PhotoServiceDto dto) {
    return PhotoService(
      id: dto.id,
      photographerId: dto.photographerId,
      title: dto.title,
      imageUrl: dto.imageUrl,
      categories: dto.categories,
      price: dto.price,
      rating: dto.rating,
      reviewCount: dto.reviewCount,
      isLiked: dto.isLiked,
      description: dto.description,
      // TODO: DTO에서 priceOptions, portfolioImages 매핑 추가
      priceOptions: [], // 임시로 빈 리스트
      portfolioImages: [], // 임시로 빈 리스트
    );
  }

  PhotoServiceDto toDto() {
    return PhotoServiceDto(
      id: id,
      photographerId: photographerId,
      title: title,
      imageUrl: imageUrl,
      categories: categories,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      isLiked: isLiked,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  PhotoService copyWith({
    int? id,
    int? photographerId,
    String? title,
    String? imageUrl,
    List<String>? categories,
    int? price,
    double? rating,
    int? reviewCount,
    bool? isLiked,
    String? description,
    List<PriceOption>? priceOptions,
    List<String>? portfolioImages,
  }) {
    return PhotoService(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isLiked: isLiked ?? this.isLiked,
      description: description ?? this.description,
      priceOptions: priceOptions ?? this.priceOptions,
      portfolioImages: portfolioImages ?? this.portfolioImages,
    );
  }

  // 편의 메서드들
  int get minPrice => priceOptions.isEmpty
      ? price
      : priceOptions.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  int get maxPrice => priceOptions.isEmpty
      ? price
      : priceOptions.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  bool get hasMultipleOptions => priceOptions.length > 1;
  String get priceRange => hasMultipleOptions
      ? '${minPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원~'
      : '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';

  // 기본 옵션들 생성 (데이터가 없을 때 사용)
  List<PriceOption> get defaultOptions => [
        PriceOption(
          name: '에센셜',
          price: price,
          duration: '1시간',
          photoCount: '20장',
          editingLevel: '기본 보정',
          features: const ['스튜디오 촬영', '기본 의상 제공', '48시간 내 전달'],
        ),
        PriceOption(
          name: '프리미엄',
          price: (price * 1.5).round(),
          duration: '2시간',
          photoCount: '50장',
          editingLevel: '고급 보정',
          features: const ['실외 + 스튜디오', '의상 컨설팅', '소품 제공', '24시간 내 전달'],
        ),
        PriceOption(
          name: '시그니처',
          price: (price * 2.5).round(),
          duration: '3시간',
          photoCount: '100장',
          editingLevel: '프리미엄 보정',
          features: const ['장소 제한 없음', '프리미엄 의상', '전문 메이크업', '당일 전달', '인화본 제공'],
        ),
      ];

  // 실제 사용할 옵션들 (데이터가 있으면 사용, 없으면 기본값)
  List<PriceOption> get availableOptions =>
      priceOptions.isNotEmpty ? priceOptions : defaultOptions;
}
