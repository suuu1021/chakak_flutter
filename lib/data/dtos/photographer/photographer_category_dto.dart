class PhotographerCategoryDto {
  final String id;
  final String name;

  PhotographerCategoryDto({
    required this.id,
    required this.name,
  });

  factory PhotographerCategoryDto.fromJson(Map<String, dynamic> json) {
    return PhotographerCategoryDto(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
