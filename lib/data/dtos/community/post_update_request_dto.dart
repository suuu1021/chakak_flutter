class PostUpdateRequestDto {
  final String title;
  final String content;
  final String? imageData;

  PostUpdateRequestDto({
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
