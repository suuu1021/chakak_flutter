import '../models/photo_service/photo_service.dart';
import '../models/photo_service/price_option.dart'; // Assuming this model is still relevant for toModel()

class PhotoServiceDto {
  final int id;
  final int photographerId;
  final int photographerUserId; // 추가: 포토그래퍼의 사용자 ID
  final String title;
  final String description;
  final String imageUrl;
  final List<String> categories;
  final int price;
  final double rating;
  final int reviewCount;
  final bool isLiked;
  final List<PriceOptionDto> priceOptions;
  final List<String> portfolioImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  PhotoServiceDto({
    required this.id,
    required this.photographerId,
    required this.photographerUserId, // 생성자에 추가
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.categories,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.isLiked = false,
    this.priceOptions = const [],
    this.portfolioImages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory PhotoServiceDto.fromJson(Map<String, dynamic> json) {
    List<String> categoryNames = [];
    if (json['categoryList'] != null && json['categoryList'] is List) {
      for (var categoryItem in (json['categoryList'] as List<dynamic>)) {
        if (categoryItem is Map<String, dynamic> &&
            categoryItem['categoryName'] != null) {
          categoryNames.add(categoryItem['categoryName'] as String);
        }
      }
    }

    List<PriceOptionDto> priceOptionDtos = [];
    if (json['priceInfoList'] != null && json['priceInfoList'] is List) {
      priceOptionDtos = (json['priceInfoList'] as List<dynamic>)
          .map((item) => PriceOptionDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return PhotoServiceDto(
      id: json['serviceId'] ?? 0,
      photographerId: json['photographerId'] ?? 0,
      photographerUserId: json['photographerUserId'] ?? json['userId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageData'] ?? '',
      categories: categoryNames,
      price: json['price'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      priceOptions: priceOptionDtos,
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'serviceId': id,
      'photographerId': photographerId,
      'userId': photographerUserId, // toJson에 추가
      'title': title,
      'description': description,
      'imageData': imageUrl,
      'categoryList': categories.map((name) => {'categoryName': name}).toList(),
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'isLiked': isLiked,
      'priceInfoList': priceOptions.map((option) => option.toJson()).toList(),
      'portfolioImages': portfolioImages,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PhotoServiceDto copyWith({
    int? id,
    int? photographerId,
    int? photographerUserId, // copyWith에 추가
    String? title,
    String? description,
    String? imageUrl,
    List<String>? categories,
    int? price,
    double? rating,
    int? reviewCount,
    bool? isLiked,
    List<PriceOptionDto>? priceOptions,
    List<String>? portfolioImages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotoServiceDto(
      id: id ?? this.id,
      photographerId: photographerId ?? this.photographerId,
      photographerUserId:
          photographerUserId ?? this.photographerUserId, // copyWith 로직에 추가
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isLiked: isLiked ?? this.isLiked,
      priceOptions: priceOptions ?? this.priceOptions,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  PhotoService toModel() {
    return PhotoService(
      id: id,
      photographerId: photographerId,
      photographerUserId: photographerUserId, // toModel에 추가
      title: title,
      description: description,
      imageUrl: imageUrl,
      categories: categories,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      isLiked: isLiked,
      priceOptions: priceOptions
          .map((priceOptionDto) => priceOptionDto.toModel())
          .toList(),
      portfolioImages: portfolioImages,
    );
  }
}

class PriceOptionDto {
  final int id; // 새로운 필드 추가
  final String name;
  final int price;
  final String duration;
  final String photoCount;
  final String editingLevel;
  final List<String> features;

  const PriceOptionDto({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.photoCount,
    required this.editingLevel,
    required this.features,
  });

  factory PriceOptionDto.fromJson(Map<String, dynamic> json) {
    List<String> constructedFeatures = [];
    if (json['specialEquipment'] != null) {
      String equipment = json['specialEquipment'].toString();
      if (equipment.startsWith('장비:')) {
        String cleanEquipment = equipment.split('장비:').last.trim();
        constructedFeatures.add('장비: $cleanEquipment');
      } else {
        constructedFeatures.add('장비: $equipment');
      }
    }
    if (json['isMakeupService'] == true) {
      constructedFeatures.add('메이크업 서비스 포함');
    }
    if (json['outfitChanges'] != null && json['outfitChanges'] > 0) {
      constructedFeatures.add('의상 변경 ${json['outfitChanges']}회');
    }

    return PriceOptionDto(
      id: json['priceInfoId'] ?? 0, // priceInfoId 필드에 맞춰 파싱
      name: json['title'] ?? 'Unknown Option',
      price: json['price'] ?? 0,
      duration: json['shootingDuration'] != null
          ? '${json['shootingDuration']}분'
          : '시간 협의',
      photoCount: json['participantCount'] != null
          ? '${json['participantCount']}명'
          : '인원 협의',
      editingLevel: json['isMakeupService'] == true ? '메이크업 포함' : '기본 보정',
      features:
          constructedFeatures.isNotEmpty ? constructedFeatures : ['기본 서비스'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priceInfoId': id,
      'title': name,
      'price': price,
      'shootingDuration': duration,
      'specialEquipment':
          features.firstWhere((f) => f.startsWith('장비: '), orElse: () => ''),
      'isMakeupService': features.contains('메이크업 서비스 포함'),
      'outfitChanges': features
          .firstWhere((f) => f.startsWith('의상 변경 '), orElse: () => '0')
          .replaceAll(RegExp(r'[^0-9]'), ''),
    };
  }

  PriceOption toModel() {
    return PriceOption(
      id: id,
      name: name,
      price: price,
      duration: duration,
      photoCount: photoCount,
      editingLevel: editingLevel,
      features: features,
    );
  }
}
