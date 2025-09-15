import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (골든 아워 기반)
  static const Color primary = Color(0xFFF4A460); // 골든 아워 샌디 브라운
  static const Color primaryLight = Color(0xFFFFF4EA); // 밝은 골든 톤
  static const Color primaryDark = Color(0xFFB8834A); // 진한 골든 톤

  // Secondary Colors (사진의 따뜻함과 차가움의 균형)
  static const Color secondary = Color(0xFF4A6FA5); // 차분한 블루 (하늘색 느낌)
  static const Color secondaryLight = Color(0xFF7A9BCF); // 밝은 블루
  static const Color secondaryDark = Color(0xFF2E4A73); // 진한 블루

  // Accent Colors (포인트 컬러)
  static const Color accent = Color(0xFFFF8A65); // 따뜻한 코랄 (선셋 느낌)
  static const Color accentLight = Color(0xFFFFBCAA); // 밝은 코랄

  // Neutral Colors (회색 톤)
  static const Color gray50 = Color(0xFFF9F9F9); // 가장 밝은 회색
  static const Color gray100 = Color(0xFFF5F5F5); // 밝은 회색
  static const Color gray200 = Color(0xFFEEEEEE); // 연한 회색
  static const Color gray300 = Color(0xFFE0E0E0); // 보통 회색
  static const Color gray400 = Color(0xFFBDBDBD); // 중간 회색
  static const Color gray500 = Color(0xFF9E9E9E); // 진한 회색
  static const Color gray600 = Color(0xFF757575); // 더 진한 회색
  static const Color gray700 = Color(0xFF616161); // 어두운 회색
  static const Color gray800 = Color(0xFF424242); // 매우 어두운 회색
  static const Color gray900 = Color(0xFF212121); // 가장 어두운 회색

  // Background Colors
  static const Color background = Color(0xFFFFFDF8); // 따뜻한 화이트 (크림톤)
  static const Color surface = Colors.white; // 순수한 화이트
  static const Color surfaceDark = Color(0xFFF8F8F8); // 살짝 어두운 표면
  static const Color overlay = Color(0x66000000); // 반투명 오버레이
  static const Color overlayLight = Color(0x33000000); // 밝은 오버레이

  // Text Colors
  static const Color textPrimary = Color(0xFF2C2C2C); // 부드러운 검정 (순수 검정보다 편안함)
  static const Color textSecondary = Color(0xFF6B6B6B); // 중간 회색 텍스트
  static const Color textTertiary = Color(0xFF9E9E9E); // 연한 회색 텍스트
  static const Color textOnPrimary = Colors.white; // Primary 색상 위의 텍스트
  static const Color textOnSecondary = Colors.white; // Secondary 색상 위의 텍스트
  static const Color textOnAccent = Colors.white; // Accent 색상 위의 텍스트
  static const Color textDisabled = Color(0xFFBDBDBD); // 비활성화된 텍스트

  // Border & Divider Colors
  static const Color border = Color(0xFFE0E0E0); // 기본 테두리
  static const Color borderLight = Color(0xFFF0F0F0); // 밝은 테두리
  static const Color borderDark = Color(0xFFBDBDBD); // 진한 테두리
  static const Color divider = Color(0xFFEEEEEE); // 구분선

  // Shadow Colors
  static const Color shadow = Color(0x1A000000); // 기본 그림자
  static const Color shadowLight = Color(0x0D000000); // 밝은 그림자
  static const Color shadowDark = Color(0x33000000); // 진한 그림자

  // Status Colors (사진 서비스에 맞게 조정)
  static const Color success = Color(0xFF4CAF50); // 성공 (예약 완료 등)
  static const Color error = Color(0xFFF44336); // 오류
  static const Color warning = Color(0xFFFF9800); // 경고
  static const Color info = Color(0xFF2196F3); // 정보

  // Photography Specific Colors (사진 관련 특별 색상)
  static const Color cameraBlack = Color(0xFF1C1C1C); // 카메라 바디 색상
  static const Color filmVintage = Color(0xFFF5E6D3); // 빈티지 필름 색상
  static const Color studioWhite = Color(0xFFFAFAFA); // 스튜디오 화이트
  static const Color darkroom = Color(0xFF2D1B1B); // 암실 색상

  // Special Effects (특수 효과용)
  static const Color shimmer = Color(0xFFE3E3E3); // 쉬머 효과
  static const Color shimmerHighlight = Color(0xFFF5F5F5); // 쉬머 하이라이트

  // Utility Colors (유틸리티)
  static const Color transparent = Colors.transparent;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
}
