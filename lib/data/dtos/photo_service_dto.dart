import '../models/photo_service/photo_service.dart';
import '../models/photo_service/price_option.dart'; // Assuming this model is still relevant for toModel()

class PhotoServiceDto {
  final int id;
  final int photographerId; // TODO: Not in the new service list item JSON, defaults to 0. Verify if needed from another source or if API changed.
  final String title;
  final String description;
  final String imageUrl;
  final List<String> categories;
  final int price;
  final double rating; // TODO: Not in the new service list item JSON, defaults to 0.0. Verify.
  final int reviewCount; // TODO: Not in the new service list item JSON, defaults to 0. Verify.
  final bool isLiked; // Usually client-side state
  final List<PriceOptionDto> priceOptions;
  final List<String> portfolioImages; // TODO: Not in the new service list item JSON, defaults to empty list. Verify.
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.priceOptions = const [],
    this.portfolioImages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory PhotoServiceDto.fromJson(Map<String, dynamic> json) {
    List<String> categoryNames = [];
    if (json['categoryList'] != null && json['categoryList'] is List) {
      for (var categoryItem in (json['categoryList'] as List<dynamic>)) {
        if (categoryItem is Map<String, dynamic> && categoryItem['categoryName'] != null) {
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
      photographerId: json['photographerId'] ?? 0, // Defaulting as not in service item JSON
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageData'] ?? '', // Mapped from imageData
      categories: categoryNames,
      price: json['price'] ?? 0, // Directly from service item JSON
      rating: (json['rating'] ?? 0.0).toDouble(), // Not in JSON, defaults to 0.0
      reviewCount: json['reviewCount'] ?? 0, // Not in JSON, defaults to 0
      isLiked: json['isLiked'] ?? false, // Not in JSON, defaults to false
      priceOptions: priceOptionDtos,
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []), // Not in JSON, defaults to empty
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(), // Fallback to DateTime.now() if null, consider if this is appropriate
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(), // Fallback to DateTime.now() if null
    );
  }

  Map<String, dynamic> toJson() {
    // This toJson might need adjustment if you send data back to an API expecting the new structure
    return {
      'serviceId': id, // Changed to serviceId to match new JSON
      'photographerId': photographerId,
      'title': title,
      'description': description,
      'imageData': imageUrl, // Changed to imageData
      'categoryList': categories.map((name) => {'categoryName': name}).toList(), // Approximate inverse
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
   // copyWith might need to be re-evaluated based on fields that are no longer present or changed.
   // For now, keeping it as is from the provided file.
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
    List<PriceOptionDto>? priceOptions,
    List<String>? portfolioImages,
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
      priceOptions: priceOptions ?? this.priceOptions,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  PhotoService toModel() {
    return PhotoService(
      id: id,
      photographerId: photographerId, // DTO에 photographerId가 있다면 PhotoService 모델에도 있어야 합니다.
      title: title,
      description: description, // DTO에 description이 있다면 PhotoService 모델에도 있어야 합니다.
      imageUrl: imageUrl,
      categories: categories,
      price: price, // DTO에 price가 있다면 PhotoService 모델에도 있어야 합니다.
      rating: rating, // DTO에 rating이 있다면 PhotoService 모델에도 있어야 합니다.
      reviewCount: reviewCount, // DTO에 reviewCount가 있다면 PhotoService 모델에도 있어야 합니다.
      isLiked: isLiked, // DTO에 isLiked가 있다면 PhotoService 모델에도 있어야 합니다.
      priceOptions: priceOptions.map((priceOptionDto) => priceOptionDto.toModel()).toList(), // PriceOptionDto에도 toModel()이 있어야 합니다.
      portfolioImages: portfolioImages, // DTO에 portfolioImages가 있다면 PhotoService 모델에도 있어야 합니다.
    );
  }
}

class PriceOptionDto {
  final String name;
  final int price;
  final String duration;
  final String photoCount; // Not in new JSON for priceInfoList
  final String editingLevel; // Not in new JSON for priceInfoList
  final List<String> features;

  const PriceOptionDto({
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
      constructedFeatures.add('특수 장비: ${json['specialEquipment']}');
    }
    if (json['makeupService'] == true) {
      constructedFeatures.add('메이크업 서비스 포함');
    }
    if (json['outfitChanges'] != null) {
      constructedFeatures.add('의상 변경 ${json['outfitChanges']}회');
    }
     if (json['participantCount'] != null) {
      constructedFeatures.add('참여 인원: ${json['participantCount']}명');
    }


    return PriceOptionDto(
      name: json['priceInfoId'] != null ? '옵션 ID: ${json['priceInfoId']}' : '기본 옵션', // Placeholder name
      price: json['price'] ?? 0,
      duration: json['shootingDuration'] != null ? '${json['shootingDuration']}시간' : '시간 협의',
      photoCount: json['photoCount'] ?? '사진 수 협의', // Not in new JSON
      editingLevel: json['editingLevel'] ?? '보정 수준 협의', // Not in new JSON
      features: constructedFeatures.isNotEmpty ? constructedFeatures : (json['features'] != null ? List<String>.from(json['features']) : ['상세 내용 문의']), // Fallback for features
    );
  }

  Map<String, dynamic> toJson() {
    // This toJson might need adjustment if you send data back to an API
    return {
      'name': name, // Or perhaps priceInfoId if that's what the server expects
      'price': price,
      'shootingDuration': duration.replaceAll('시간', ''), // Approximate inverse
      // photoCount, editingLevel are not directly mapped back from the current structure
      'features': features, // This might need more specific field mapping back
    };
  }

  PriceOption toModel() {
    return PriceOption(
      name: name,
      price: price,
      duration: duration,
      photoCount: photoCount,
      editingLevel: editingLevel,
      features: features,
    );
  }
}
