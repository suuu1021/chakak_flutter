import '../../dtos/photo_service/photo_service_category_dto.dart';

class PhotoServiceCategory {
  final String id;
  final String name;
  final String categoryImageData;

  PhotoServiceCategory({
    required this.id,
    required this.name,
    required this.categoryImageData,
  });

  factory PhotoServiceCategory.fromDto(PhotoServiceCategoryDto dto) {
    return PhotoServiceCategory(
      id: dto.id,
      name: dto.name,
      categoryImageData: dto.categoryImageData,
    );
  }

  PhotoServiceCategoryDto toDto() {
    return PhotoServiceCategoryDto(
      id: id,
      name: name,
      categoryImageData: categoryImageData,
    );
  }

  PhotoServiceCategory copyWith({
    String? id,
    String? name,
    String? categoryImageData,
  }) {
    return PhotoServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryImageData: categoryImageData ?? this.categoryImageData,
    );
  }
}
