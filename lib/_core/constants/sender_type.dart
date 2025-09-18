enum SenderType {
  USER,
  PHOTOGRAPHER,
  UNKNOWN; // 예외 처리를 위한 기본값

  // 서버와 통신할 때 실제 문자열 값을 사용하기 위한 컨버터
  String get toJson => name;

  // 대소문자 구분 없이 값을 비교하여 Enum을 반환
  static SenderType fromJson(String name) =>
      values.firstWhere((e) => e.name == name.toUpperCase(), orElse: () => UNKNOWN);
}
