# CHAKAK (찰칵) 📸

사진작가와 고객을 연결하는 포토 서비스 매칭 플랫폼

## 📋 프로젝트 소개

CHAKAK은 일반 사용자와 전문 사진작가를 연결하는 모바일 애플리케이션입니다. 사용자는 원하는 촬영 서비스를 찾아 예약하고, 사진작가는 자신의 포트폴리오와 서비스를 등록하여 고객을 만날 수 있습니다.

### 주요 특징

- 🎨 **포트폴리오 관리**: 사진작가의 작품을 카테고리별로 관리
- 📅 **예약 시스템**: 실시간 예약 및 일정 관리
- 💬 **실시간 채팅**: STOMP 기반 1:1 채팅 지원
- 💳 **통합 결제**: 안전한 온라인 결제 시스템
- ⭐ **리뷰 시스템**: 양방향 평가 및 피드백
- 👥 **커뮤니티**: 사진 관련 정보 공유 게시판

## 🛠 기술 스택

### Framework & Language
- **Flutter** 3.6.2
- **Dart** 3.6.2

### 주요 패키지

#### 상태 관리 & 아키텍처
- `flutter_riverpod: ^2.3.6` - 상태 관리
- `dio: ^5.2.0` - HTTP 클라이언트
- `logger: ^1.3.0` - 로깅

#### UI & UX
- `flutter_svg: ^2.0.6` - SVG 이미지 렌더링
- `cached_network_image: ^3.4.1` - 이미지 캐싱
- `carousel_slider: ^5.1.1` - 배너 슬라이더

#### 기능
- `stomp_dart_client: ^2.1.3` - 실시간 채팅 (WebSocket)
- `image_picker: ^1.0.7` - 이미지 선택
- `permission_handler: ^11.3.1` - 권한 관리
- `flutter_secure_storage: ^8.0.0` - 보안 저장소
- `shared_preferences: ^2.5.3` - 로컬 저장소

#### 유틸리티
- `intl: ^0.18.1` - 국제화 및 날짜 포맷
- `validators: ^3.0.0` - 유효성 검사
- `share_plus: ^7.2.1` - 콘텐츠 공유
- `url_launcher: ^6.2.2` - 외부 링크 실행

## 📁 프로젝트 구조

```
lib/
├── _core/                          # 핵심 유틸리티 및 상수
│   ├── constants/                  # 앱 전역 상수
│   │   ├── app_colors.dart
│   │   ├── app_routes.dart
│   │   ├── app_strings.dart
│   │   ├── app_text_styles.dart
│   │   ├── sender_type.dart
│   │   └── user_type.dart
│   └── utils/                      # 유틸리티 함수
│       ├── error_handler.dart
│       ├── image_utils.dart
│       ├── permission_util.dart
│       └── validator_util.dart
│
├── data/                           # 데이터 레이어
│   ├── dtos/                       # 데이터 전송 객체
│   │   ├── auth_dto.dart
│   │   ├── booking/
│   │   ├── chat_*.dart
│   │   ├── community/
│   │   ├── payment/
│   │   └── review/
│   └── models/                     # 도메인 모델
│       ├── repositories/           # Repository 인터페이스
│       ├── booking/
│       ├── community/
│       ├── photo_service/
│       └── *.dart
│
├── provider/                       # 상태 관리 (Riverpod)
│   ├── auth/
│   ├── chat/
│   ├── global/                     # 전역 상태
│   │   ├── banner/
│   │   ├── booking/
│   │   ├── category/
│   │   ├── community/
│   │   ├── photographer/
│   │   ├── photoService/
│   │   └── portfolio/
│   ├── payment/
│   └── review/
│
├── service/                        # API 서비스
│   ├── auth_service.dart
│   ├── payment_service.dart
│   ├── portfolio_api_service.dart
│   └── user_profile_service.dart
│
└── ui/                             # UI 레이어
    ├── pages/                      # 화면
    │   ├── auth/                   # 인증 (로그인/회원가입)
    │   ├── booking/                # 예약 관리
    │   ├── chat/                   # 채팅
    │   ├── community/              # 커뮤니티
    │   ├── help_center/            # 고객센터
    │   ├── home/                   # 홈
    │   ├── notification/           # 알림
    │   ├── payment/                # 결제
    │   ├── photo_service/          # 포토 서비스
    │   ├── portfolio/              # 포트폴리오
    │   ├── profile/                # 프로필
    │   ├── review/                 # 리뷰
    │   ├── search/                 # 검색
    │   └── splash/                 # 스플래시/온보딩
    └── widgets/                    # 공통 위젯
        ├── custom_appbar.dart
        ├── custom_button_widgets.dart
        ├── custom_text_form_field.dart
        └── ...
```

## 🎯 주요 기능

### 1. 사용자 기능
- ✅ 이메일 회원가입
- ✅ 사진작가 검색 및 필터링
- ✅ 포토 서비스 예약
- ✅ 실시간 채팅을 통한 상담
- ✅ 온라인 결제
- ✅ 예약 내역 관리
- ✅ 리뷰 작성 및 조회
- ✅ 커뮤니티 게시판

### 2. 사진작가 기능
- ✅ 프로필 등록 및 관리
- ✅ 포트폴리오 등록 (카테고리별)
- ✅ 포토 서비스 등록
- ✅ 예약 요청 관리
- ✅ 고객과 실시간 채팅
- ✅ 결제 내역 조회
- ✅ 리뷰 관리
- ✅ 커뮤니티 게시판

### 99. 공통 기능
- ✅ 배너 광고 시스템
- ✅ 검색 히스토리
- ✅ 푸시 알림
- ✅ 이미지 업로드 및 관리
- ✅ 공유 기능

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK 3.6.2 이상
- Dart 3.6.2 이상
- Android Studio

### 설치 방법

1. **저장소 클론**
```bash
git clone https://github.com/your-username/chakak_flutter.git
cd chakak_flutter
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **환경 설정**
```bash
# .env 파일 생성 (필요시)
# API 키, 서버 URL 등 설정
```

4. **앱 실행**
```bash
# 개발 모드
flutter run

## 🏗 아키텍처

### 레이어 구조

```
UI Layer (Presentation)
    ↓
Provider Layer (State Management)
    ↓
Service Layer (Business Logic)
    ↓
Repository Layer (Data Access)
    ↓
DTO/Model Layer (Data)
```

### 설계 원칙

- **단일 책임 원칙**: 각 클래스는 하나의 책임만 가짐
- **의존성 주입**: Riverpod을 통한 DI 구현
- **레이어 분리**: UI, 비즈니스 로직, 데이터 레이어 명확히 구분
- **Repository 패턴**: 데이터 소스 추상화

## 📱 주요 화면

### 인증 플로우
- 스플래시 → 온보딩 → 로그인 선택 → 로그인/회원가입

### 메인 플로우
- 홈 → 검색 → 서비스 상세 → 예약 → 결제 → 채팅 → 리뷰

### 사진작가 플로우
- 프로필 등록 → 포트폴리오 등록 → 서비스 등록 → 예약 관리

## 🔐 보안

- **flutter_secure_storage**: 민감한 정보 암호화 저장
- **토큰 기반 인증**: JWT 토큰 사용
- **HTTPS 통신**: 모든 API 통신 암호화

## 📝 코딩 컨벤션

### 파일 명명 규칙
- 모델: `*.dart` (예: `photographer.dart`)
- DTO: `*_dto.dart` (예: `photographer_dto.dart`)
- Provider: `*_provider.dart` 또는 `*_notifier.dart`
- 화면: `*_screen.dart` 또는 `*_page.dart`
- 위젯: `*_widget.dart`

### 코드 스타일
- 상수는 대문자 스네이크 케이스
- 메서드는 카멜 케이스
- 클래스는 파스칼 케이스


## 👥 팀

- **개발자**
- [위희수] 메인 화면, 검색 화면, 채팅 내 예약 생성 및 결제 요청화면, 예약관리 화면, 포토 서비스 화면 기능 관리 전체 UI 개발 기획
- [이승민] 스플래시 화면, 온보딩 화면, 로그인 화면, 회원가입 화면, 고객센터 화면, 리뷰 관련 화면, KakaoPay 결제, 결제 내역 화면
- [이예람] 포토그래퍼 프로필, 커뮤니티, 마이페이지 화면 및 포트폴리오 관련 기능 관리
- [장승원] 로그인 화면 기능 연결, 회원가입 기능 연결, 리뷰 저장 및 평점 연결
- [문한영] 채팅방, 채팅 리스트, 이메일 로그인 기능 연결
- [오승운] 커뮤니티 화면 기능 관리
- [황희곤] 메인화면 목록 데이터들 조회 기능 연결
