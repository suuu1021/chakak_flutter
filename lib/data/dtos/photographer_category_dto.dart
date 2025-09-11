class PhotographerCategoryDto {
  final String id;
  final String name;
  final String categoryImageData;
  final String? backgroundColor;

  PhotographerCategoryDto({
    required this.id,
    required this.name,
    required this.categoryImageData,
    this.backgroundColor,
  });

  factory PhotographerCategoryDto.fromJson(Map<String, dynamic> json) {
    return PhotographerCategoryDto(
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
