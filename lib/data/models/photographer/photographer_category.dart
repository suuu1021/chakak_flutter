import '../../dtos/photographer/photographer_category_dto.dart';

class PhotographerCategory {
  final String id;
  final String name;

  PhotographerCategory({
    required this.id,
    required this.name,
  });

  factory PhotographerCategory.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'] ?? json['categoryId'];
    if (rawId == null) {
      throw FormatException('카테고리 ID가 없습니다.');
    }
    final String id = rawId.toString();

    final String? name = json['name'] ?? json['categoryName'];
    if (name == null) {
      throw FormatException('카테고리 이름이 없습니다.');
    }

    return PhotographerCategory(
      id: id,
      name: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

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

  @override
  String toString() => 'PhotographerCategory(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotographerCategory &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
