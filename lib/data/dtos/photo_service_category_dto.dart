import '../models/photo_service_category.dart';

class PhotoServiceCategoryDto {
  final String id;
  final String name;
  final String categoryImageData;

  PhotoServiceCategoryDto({
    required this.id,
    required this.name,
    required this.categoryImageData,
  });

  factory PhotoServiceCategoryDto.fromJson(Map<String, dynamic> json) {
    return PhotoServiceCategoryDto(
      id: json['categoryId']?.toString() ?? '', // int를 String으로 변환, null일 경우 빈 문자열
      name: json['categoryName'] as String? ?? '', // null일 경우 빈 문자열
      categoryImageData: json['categoryImageData'] as String? ?? '', // null일 경우 빈 문자열
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_image_data': categoryImageData,
    };
  }

  factory PhotoServiceCategoryDto.fromModel(PhotoServiceCategory model) {
    return PhotoServiceCategoryDto(
      id: model.id,
      name: model.name,
      categoryImageData: model.categoryImageData,
    );
  }

  // DTO에서 Model로 변환
  PhotoServiceCategory toModel() {
    return PhotoServiceCategory(
      id: id,
      name: name,
      categoryImageData: categoryImageData,
    );
  }
}
