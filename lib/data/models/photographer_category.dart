import '../dtos/photographer_category_dto.dart';

class PhotographerCategory {
  final String id;
  final String name;

  PhotographerCategory({
    required this.id,
    required this.name,
  });

  factory PhotographerCategory.fromDto(PhotographerCategoryDto dto) {
    return PhotographerCategory(
      id: dto.id,
      name: dto.name,
    );
  }

  PhotographerCategoryDto toDto() {
    return PhotographerCategoryDto(
      id: id,
      name: name,
    );
  }

  PhotographerCategory copyWith({
    String? id,
    String? name,
  }) {
    return PhotographerCategory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
