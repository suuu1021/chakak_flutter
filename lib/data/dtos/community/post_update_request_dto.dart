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
/*
  이 클래스는 기존 게시글을 수정할 때 서버로 보낼 데이터를 담는 DTO입니다.
  게시글 생성 DTO와 동일하게 `toJson` 메서드를 사용하여 데이터를 JSON으로 변환합니다.
*/
