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
/*
  이 클래스는 게시글을 새로 생성할 때 서버로 보낼 데이터를 담는 DTO입니다.
  `toJson` 메서드를 통해 Dart 객체를 서버가 이해할 수 있는 JSON 형식으로 변환합니다.
*/
