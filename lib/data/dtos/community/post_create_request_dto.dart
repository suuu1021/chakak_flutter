class PostCreateRequestDto {
  final String title;
  final String content;
  final String? imageData;

  PostCreateRequestDto({
    required this.title,
    required this.content,
    this.imageData,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'imageData': imageData,
    };
  }
}
