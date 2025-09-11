// lib/data/dto/photo_service_category_dto.dart
class PhotoServiceCategoryDto {
  final String id;
  final String name;
  final String categoryImageData;
  final String? backgroundColor;

  PhotoServiceCategoryDto({
    required this.id,
    required this.name,
    required this.categoryImageData,
    this.backgroundColor,
  });

  factory PhotoServiceCategoryDto.fromJson(Map<String, dynamic> json) {
    return PhotoServiceCategoryDto(
      id: json['id'],
      name: json['name'],
      categoryImageData: json['category_image_data'],
      backgroundColor: json['background_color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_image_data': categoryImageData,
      'background_color': backgroundColor,
    };
  }
}
