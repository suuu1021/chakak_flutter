import 'dart:ui';

import '../dtos/photo_service_category_dto.dart';

class PhotoServiceCategory {
  final String id;
  final String name;
  final String categoryImageData;
  final Color? backgroundColor;

  PhotoServiceCategory({
    required this.id,
    required this.name,
    required this.categoryImageData,
    this.backgroundColor,
  });

  factory PhotoServiceCategory.fromDto(PhotoServiceCategoryDto dto) {
    return PhotoServiceCategory(
      id: dto.id,
      name: dto.name,
      categoryImageData: dto.categoryImageData,
      backgroundColor: dto.backgroundColor != null
          ? _parseColor(dto.backgroundColor!)
          : null,
    );
  }

  PhotoServiceCategoryDto toDto() {
    return PhotoServiceCategoryDto(
      id: id,
      name: name,
      categoryImageData: categoryImageData,
      backgroundColor: backgroundColor?.value.toRadixString(16),
    );
  }

  PhotoServiceCategory copyWith({
    String? id,
    String? name,
    String? categoryImageData,
    Color? backgroundColor,
  }) {
    return PhotoServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryImageData: categoryImageData ?? this.categoryImageData,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  static Color? _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        colorString = colorString.substring(1);
      }
      if (colorString.length == 6) {
        colorString = 'FF$colorString';
      }
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return null;
    }
  }
}
