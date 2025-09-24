// lib/services/api/portfolio_api_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

// 페이징 응답 데이터 클래스 (클래스 외부에서 정의)
class PaginatedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool isLast;
  final bool hasNext;

  const PaginatedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.isLast,
    required this.hasNext,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse<T>(
      content: List<T>.from(json['content'] ?? []),
      page: json['number'] ?? 0,
      size: json['size'] ?? 10,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      isLast: json['last'] ?? true,
      hasNext: !(json['last'] ?? true),
    );
  }
}

/// Portfolio 관련 HTTP API 호출을 담당하는 서비스 클래스
class PortfolioApiService {
  final Dio _dio;
  static const String _baseUrl = '/api/portfolios';

  PortfolioApiService(this._dio);

  /// 모든 포트폴리오 목록 조회 (기존 방식)
  /// GET /api/portfolios
  Future<List<Map<String, dynamic>>> fetchPortfolios() async {
    try {
      final response = await _dio.get(_baseUrl);

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('body')) {
          final body = responseData['body'];

          if (body is Map<String, dynamic> && body.containsKey('content')) {
            // 페이징된 응답: Page<T> 구조
            return List<Map<String, dynamic>>.from(body['content']);
          } else if (body is List) {
            // 직접 배열 응답
            return List<Map<String, dynamic>>.from(body);
          } else {
            throw Exception('예상하지 못한 body 구조: ${body.runtimeType}');
          }
        } else {
          throw Exception('응답에 body 필드가 없습니다');
        }
      } else {
        throw Exception('응답이 Map 타입이 아닙니다: ${responseData.runtimeType}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '포트폴리오 목록 조회');
    }
  }

  /// 포트폴리오 목록 조회 (페이징 정보 포함) - 클래스 내부로 이동
  /// GET /api/portfolios?page=0&size=10
  Future<PaginatedResponse<Map<String, dynamic>>> fetchPortfoliosPaginated({
    int page = 0,
    int size = 10,
  }) async {
    try {
      print('=== 페이징 포트폴리오 요청 ===');
      print('URL: $_baseUrl');
      print('파라미터: page=$page, size=$size');

      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      print('=== 페이징 포트폴리오 응답 ===');
      print('상태 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('body')) {
          final body = responseData['body'];

          if (body is Map<String, dynamic> && body.containsKey('content')) {
            // 페이징 정보 상세 로그 추가
            print('=== 페이징 정보 상세 ===');
            print('content 길이: ${body['content'].length}');
            print('number: ${body['number']}');
            print('size: ${body['size']}');
            print('totalElements: ${body['totalElements']}');
            print('totalPages: ${body['totalPages']}');
            print('last: ${body['last']}');
            print('first: ${body['first']}');
            print('모든 body 키: ${body.keys.toList()}');

            // 페이징된 응답: Page<T> 구조
            return PaginatedResponse<Map<String, dynamic>>(
              content: List<Map<String, dynamic>>.from(body['content']),
              page: body['number'] ?? page,
              size: body['size'] ?? size,
              totalElements: body['totalElements'] ?? 0,
              totalPages: body['totalPages'] ?? 0,
              isLast: body['last'] ?? true,
              hasNext: !(body['last'] ?? true),
            );
          } else if (body is List) {
            // 직접 배열 응답 (페이징 정보 없음)
            final content = List<Map<String, dynamic>>.from(body);
            return PaginatedResponse<Map<String, dynamic>>(
              content: content,
              page: page,
              size: content.length,
              totalElements: content.length,
              totalPages: 1,
              isLast: true,
              hasNext: false,
            );
          } else {
            throw Exception('예상하지 못한 body 구조: ${body.runtimeType}');
          }
        } else {
          throw Exception('응답에 body 필드가 없습니다');
        }
      } else {
        throw Exception('응답이 Map 타입이 아닙니다: ${responseData.runtimeType}');
      }
    } on DioException catch (e) {
      print('=== 페이징 포트폴리오 에러 ===');
      print('에러 타입: ${e.type}');
      print('상태 코드: ${e.response?.statusCode}');
      print('에러 메시지: ${e.message}');
      throw _handleDioError(e, '포트폴리오 목록 조회');
    }
  }

  /// 특정 포트폴리오 조회
  /// GET /api/portfolios/{id}
  Future<Map<String, dynamic>> fetchPortfolioById(String id) async {
    try {
      print('=== 포트폴리오 상세 조회 API 호출 ===');
      print('요청 URL: $_baseUrl/$id');
      print('포트폴리오 ID: $id');

      final response = await _dio.get('$_baseUrl/$id');

      print('=== 포트폴리오 상세 조회 응답 ===');
      print('상태 코드: ${response.statusCode}');
      print('응답 데이터 타입: ${response.data.runtimeType}');
      print(
          '응답 데이터 키들: ${response.data is Map ? (response.data as Map).keys.toList() : "배열 또는 기타"}');
      print(
          '응답 데이터 (첫 500자): ${response.data.toString().substring(0, response.data.toString().length > 500 ? 500 : response.data.toString().length)}');

      // 서버 응답 구조 확인 및 처리
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('body')) {
        print('서버 응답 구조: CommonResponse 형태 (body 포함)');
        final body = responseData['body'] as Map<String, dynamic>;
        print('body 내용 키들: ${body.keys.toList()}');

        // images 필드 특별 확인
        if (body.containsKey('images')) {
          final images = body['images'];
          print('images 필드 타입: ${images.runtimeType}');
          if (images is List) {
            print('images 배열 길이: ${images.length}');
            if (images.isNotEmpty) {
              print(
                  '첫 번째 이미지 키들: ${images[0] is Map ? (images[0] as Map).keys.toList() : "Map이 아님"}');
            }
          }
        }

        return body;
      } else {
        print('서버 응답 구조: 직접 포트폴리오 데이터');
        return responseData as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      print('=== 포트폴리오 상세 조회 에러 ===');
      print('에러 타입: ${e.type}');
      print('상태 코드: ${e.response?.statusCode}');
      print('에러 메시지: ${e.message}');
      throw _handleDioError(e, '포트폴리오 조회');
    }
  }

  /// 특정 사진작가의 포트폴리오 목록 조회
  Future<List<Map<String, dynamic>>> fetchPortfoliosByPhotographer(
      String photographerId) async {
    try {
      final response = await _dio.get('$_baseUrl/photographer/$photographerId');

      // 디버깅 로그 추가
      print('=== 작가별 포트폴리오 응답 ===');
      print('응답 데이터: ${response.data}');

      final responseData = response.data;

      // 응답 구조 확인 필요
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('body')) {
          final body = responseData['body'];

          if (body is List) {
            return List<Map<String, dynamic>>.from(body);
          } else if (body is Map && body.containsKey('content')) {
            // 페이징된 응답인 경우
            return List<Map<String, dynamic>>.from(body['content']);
          }
        }
      }

      // 직접 배열인 경우
      return List<Map<String, dynamic>>.from(responseData);
    } on DioException catch (e) {
      throw _handleDioError(e, '사진작가 포트폴리오 조회');
    }
  }

  /// 특정 사진작가의 포트폴리오 목록 조회 (페이징 지원)
  /// GET /api/portfolios/photographer/{photographerId}?page=0&size=10
  Future<PaginatedResponse<Map<String, dynamic>>>
      fetchPortfoliosByPhotographerPaginated({
    required String photographerId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      print('=== 작가별 페이징 포트폴리오 요청 ===');
      print('URL: $_baseUrl/photographer/$photographerId');
      print('파라미터: page=$page, size=$size');

      final response = await _dio.get(
        '$_baseUrl/photographer/$photographerId',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      print('=== 작가별 페이징 포트폴리오 응답 ===');
      print('상태 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('body')) {
          final body = responseData['body'];

          if (body is Map<String, dynamic> && body.containsKey('content')) {
            // 페이징된 응답: Page<T> 구조
            print('=== 작가별 페이징 정보 상세 ===');
            print('content 길이: ${body['content'].length}');
            print('totalElements: ${body['totalElements']}');
            print('last: ${body['last']}');

            return PaginatedResponse<Map<String, dynamic>>(
              content: List<Map<String, dynamic>>.from(body['content']),
              page: body['number'] ?? page,
              size: body['size'] ?? size,
              totalElements: body['totalElements'] ?? 0,
              totalPages: body['totalPages'] ?? 0,
              isLast: body['last'] ?? true,
              hasNext: !(body['last'] ?? true),
            );
          } else if (body is List) {
            // 기존 방식: 배열 응답 (페이징 정보 없음)
            final content = List<Map<String, dynamic>>.from(body);
            return PaginatedResponse<Map<String, dynamic>>(
              content: content,
              page: page,
              size: content.length,
              totalElements: content.length,
              totalPages: 1,
              isLast: true,
              hasNext: false,
            );
          }
        }
      }

      throw Exception('예상하지 못한 응답 구조');
    } on DioException catch (e) {
      print('=== 작가별 페이징 포트폴리오 에러 ===');
      print('에러 타입: ${e.type}');
      print('상태 코드: ${e.response?.statusCode}');
      throw _handleDioError(e, '작가별 포트폴리오 조회');
    }
  }

  /// 카테고리별 포트폴리오 조회
  /// GET /api/portfolios/category/{category}
  Future<List<Map<String, dynamic>>> fetchPortfoliosByCategory(
      String category) async {
    try {
      final response = await _dio.get('$_baseUrl/category/$category');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, '카테고리별 포트폴리오 조회');
    }
  }

  /// 인기 포트폴리오 조회 (좋아요 순)
  /// GET /api/portfolios/popular?limit={limit}
  Future<List<Map<String, dynamic>>> fetchPopularPortfolios(
      {int limit = 10}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/popular',
        queryParameters: {'limit': limit},
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, '인기 포트폴리오 조회');
    }
  }

  /// 포트폴리오 생성
  /// POST /api/portfolios/create
  Future<Map<String, dynamic>> createPortfolio(
      Map<String, dynamic> portfolioData) async {
    try {
      // 디버깅: 요청 데이터 로그
      print('=== 포트폴리오 생성 요청 ===');
      print('URL: $_baseUrl/create');
      print('데이터: $portfolioData');

      final response = await _dio.post(
        '$_baseUrl/create', // /create 경로 추가
        data: portfolioData,
      );

      // 디버깅: 응답 로그
      print('=== 포트폴리오 생성 응답 ===');
      print('상태 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      // 서버 응답 구조에 맞게 처리
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('body')) {
        return responseData['body'] as Map<String, dynamic>;
      } else {
        return responseData as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      print('=== 포트폴리오 생성 에러 ===');
      print('에러 타입: ${e.type}');
      print('상태 코드: ${e.response?.statusCode}');
      print('에러 메시지: ${e.message}');
      print('응답 데이터: ${e.response?.data}');
      throw _handleDioError(e, '포트폴리오 생성');
    }
  }

  /// Base64 파일 변환 및 검증 헬퍼 메서드
  Future<List<Map<String, String>>> _convertFilesToBase64(
      List<String> imagePaths) async {
    const int maxFileSize = 10 * 1024 * 1024; // 10MB 제한
    const List<String> supportedExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp'
    ];

    List<Map<String, String>> base64Images = [];

    for (String imagePath in imagePaths) {
      try {
        final file = File(imagePath);

        // 1. 파일 존재 확인
        if (!await file.exists()) {
          print('경고: 파일이 존재하지 않음 - $imagePath');
          throw Exception('파일을 찾을 수 없습니다: ${imagePath.split('/').last}');
        }

        // 2. 파일 확장자 검증
        final fileName = imagePath.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();
        if (!supportedExtensions.contains(extension)) {
          throw Exception(
              '지원하지 않는 파일 형식입니다: .$extension\n지원 형식: ${supportedExtensions.join(', ')}');
        }

        // 3. 파일 크기 검증
        final fileSize = await file.length();
        if (fileSize > maxFileSize) {
          final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
          throw Exception(
              '파일 크기가 너무 큽니다: ${sizeMB}MB\n최대 크기: ${maxFileSize ~/ (1024 * 1024)}MB');
        }

        if (fileSize == 0) {
          throw Exception('빈 파일입니다: $fileName');
        }

        // 4. 파일 읽기 및 Base64 변환
        final bytes = await file.readAsBytes();

        // 5. Base64 인코딩 (메모리 부족 가능성 체크)
        String base64String;
        try {
          base64String = base64Encode(bytes);
        } catch (e) {
          throw Exception('파일 인코딩에 실패했습니다: $fileName\n원인: 메모리 부족 또는 파일 손상');
        }

        // 6. MIME 타입 설정
        String mimeType;
        switch (extension) {
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          case 'jpg':
          case 'jpeg':
          default:
            mimeType = 'image/jpeg';
            break;
        }

        base64Images.add({
          'fileName': fileName,
          'mimeType': mimeType,
          'base64Data': base64String,
        });

        print(
            '파일 변환 성공: $fileName (${(fileSize / 1024).toStringAsFixed(1)}KB)');
      } catch (e) {
        // 개별 파일 처리 실패 시 전체 작업 중단
        print('파일 변환 실패: $imagePath - $e');
        rethrow;
      }
    }

    // 7. 전체 데이터 크기 검증 (Base64는 약 33% 증가)
    final totalBase64Size = base64Images.fold<int>(
        0, (sum, image) => sum + (image['base64Data']?.length ?? 0));

    const int maxTotalSize = 50 * 1024 * 1024; // 50MB 제한
    if (totalBase64Size > maxTotalSize) {
      final sizeMB = (totalBase64Size / (1024 * 1024)).toStringAsFixed(1);
      throw Exception(
          '전체 이미지 크기가 너무 큽니다: ${sizeMB}MB\n최대 크기: ${maxTotalSize ~/ (1024 * 1024)}MB');
    }

    print(
        'Base64 변환 완료: ${base64Images.length}개 파일, 총 ${(totalBase64Size / (1024 * 1024)).toStringAsFixed(1)}MB');
    return base64Images;
  }

  /// 포트폴리오 생성 (서버 구조에 맞춘 버전)
  /// POST /api/portfolios/create
  Future<Map<String, dynamic>> createPortfolioWithFiles({
    required String title,
    required String description,
    required List<String> categories,
    required int photographerId,
    required List<String> imagePaths,
  }) async {
    try {
      print('=== 포트폴리오 서버 맞춤 생성 요청 ===');
      print('제목: $title');
      print('이미지 파일 개수: ${imagePaths.length}');

// 카테고리 String을 실제 ID로 변환
      List<int> categoryIds = await _convertCategoriesToIds(categories);

      // Base64 이미지를 AddImageDTO 형태로 변환
      List<Map<String, dynamic>> imageInfoList = [];
      for (String imagePath in imagePaths) {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final base64String = base64Encode(bytes);
          final fileName = imagePath.split('/').last;

          // 서버 AddImageDTO 구조에 맞게 변환
          imageInfoList.add({
            'portfolioId': null, // 생성 시에는 null
            'imageData': 'data:image/jpeg;base64,$base64String', // data URL 형태
            'originalFileName': fileName,
            'isMain': imageInfoList.isEmpty, // 첫 번째를 메인으로
          });

          print('파일 변환 완료: $fileName (${bytes.length} bytes)');
        }
      }

      // 서버 DTO 구조에 맞춘 JSON 데이터
      final requestData = {
        'title': title,
        'description': description,
        'thumbnailUrl': 'temporary',
        //     imageInfoList.isNotEmpty ? imageInfoList[0]['imageData'] : null,
        'categoryIds': categoryIds, // Long 배열
        'imageInfoList': imageInfoList, // AddImageDTO 배열
      };

      print('=== 서버 전송 데이터 ===');
      print('categoryIds: $categoryIds');
      print('imageInfoList 개수: ${imageInfoList.length}');

      final response = await _dio.post(
        '$_baseUrl/create',
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      print('=== 포트폴리오 서버 맞춤 생성 응답 ===');
      print('상태 코드: ${response.statusCode}');

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('body')) {
        return responseData['body'] as Map<String, dynamic>;
      } else {
        return responseData as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      print('=== 포트폴리오 서버 맞춤 생성 에러 ===');
      print('에러: $e');
      throw _handleDioError(e, '포트폴리오 생성');
    }
  }

  /// 포트폴리오 수정
  /// PUT /api/portfolios/{id}/update
  Future<Map<String, dynamic>> updatePortfolio(
      String id, Map<String, dynamic> portfolioData) async {
    try {
      // 요청 데이터 로그
      print('=== 포트폴리오 수정 요청 ===');
      print('URL: $_baseUrl/$id');
      print('데이터: $portfolioData');

      final response = await _dio.put(
        '$_baseUrl/$id/update',
        data: portfolioData,
      );

      // 응답 데이터 로그
      print('=== 포트폴리오 수정 응답 ===');
      print('상태 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      // 서버 응답 구조에 맞게 처리
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('body')) {
        return responseData['body'] as Map<String, dynamic>;
      } else {
        return responseData as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      // 에러 데이터 로그
      print('=== 포트폴리오 수정 에러 ===');
      print('에러 타입: ${e.type}');
      print('상태 코드: ${e.response?.statusCode}');
      print('에러 메시지: ${e.message}');
      print('응답 데이터: ${e.response?.data}');

      throw _handleDioError(e, '포트폴리오 수정');
    }
  }

  /// 포트폴리오 수정 (서버 구조에 맞춘 버전)
  /// PUT /api/portfolios/{portfolioId}/update
  Future<Map<String, dynamic>> updatePortfolioWithFiles({
    required String portfolioId,
    required String title,
    required String description,
    required List<String> categories,
    required List<String> existingImageUrls,
    required List<String> newImagePaths,
  }) async {
    try {
      print('=== 포트폴리오 서버 맞춤 수정 요청 ===');
      print('포트폴리오 ID: $portfolioId');
      print('제목: $title');
      print('이미지 파일 개수: ${newImagePaths.length}');

      // 입력값 검증
      if (portfolioId.isEmpty) {
        throw Exception('포트폴리오 ID가 필요합니다.');
      }

      if (newImagePaths.length > 10) {
        throw Exception('이미지는 최대 10개까지 업로드할 수 있습니다.');
      }

      // 카테고리 String을 실제 ID로 변환
      List<int> categoryIds = await _convertCategoriesToIds(categories);

      // 전체 이미지 리스트 구성
      List<Map<String, dynamic>> imageInfoList = [];

      // 1. 기존 이미지들 추가 (URL 형태로)
      for (int i = 0; i < existingImageUrls.length; i++) {
        imageInfoList.add({
          'portfolioId': int.parse(portfolioId),
          'imageData': existingImageUrls[i], // 기존 URL을 그대로 전송
          'originalFileName': 'existing_image_${i + 1}',
          'isMain': i == 0, // 첫 번째를 메인으로
        });
        print('기존 이미지 추가: ${existingImageUrls[i]}');
      }

      // Base64 이미지를 AddImageDTO 형태로 변환
      if (newImagePaths.isNotEmpty) {
        print('=== 새 이미지 처리 시작 ===');
        for (int i = 0; i < newImagePaths.length; i++) {
          final imagePath = newImagePaths[i];
          final file = File(imagePath);

          if (await file.exists()) {
            try {
              // 파일 크기 체크
              final fileSize = await file.length();
              if (fileSize > 10 * 1024 * 1024) {
                throw Exception(
                    '이미지 파일 크기는 10MB 이하여야 합니다: ${imagePath.split('/').last}');
              }

              final bytes = await file.readAsBytes();
              final base64String = base64Encode(bytes);
              final fileName = imagePath.split('/').last;

              imageInfoList.add({
                'portfolioId': int.parse(portfolioId),
                'imageData': 'data:image/jpeg;base64,$base64String',
                'originalFileName': fileName,
                'isMain': i == 0,
              });

              print(
                  '파일 변환 완료: $fileName (${(fileSize / 1024).toStringAsFixed(1)}KB)');
            } catch (e) {
              print('파일 처리 실패: $imagePath - $e');
              throw Exception(
                  '이미지 처리 중 오류가 발생했습니다: ${imagePath.split('/').last}');
            }
          } else {
            print('경고: 파일이 존재하지 않음 - $imagePath');
            throw Exception('파일을 찾을 수 없습니다: ${imagePath.split('/').last}');
          }
        }
        print('=== 새 이미지 처리 완료: ${imageInfoList.length}개 ===');
      } else {
        print('=== 새 이미지 없음 - 기존 이미지 유지 ===');
      }
      // 서버 DTO 구조에 맞춘 JSON 데이터
      final requestData = {
        'title': title.trim(),
        'description': description.trim(),
        'categoryIds': categoryIds,
        'imageInfoList': imageInfoList, // 빈 배열이면 기존 이미지 유지
      };

      print('=== 서버 전송 데이터 ===');
      print('categoryIds: $categoryIds');
      print('imageInfoList 개수: ${imageInfoList.length}');

      final response = await _dio.put(
        '$_baseUrl/$portfolioId/update',
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      print('=== 포트폴리오 서버 맞춤 수정 응답 ===');
      print('상태 코드: ${response.statusCode}');

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('body')) {
        return responseData['body'] as Map<String, dynamic>;
      } else {
        return responseData as Map<String, dynamic>;
      }
    } catch (e) {
      print('=== 포트폴리오 서버 맞춤 수정 에러 ===');
      print('에러: $e');

      // 사용자 친화적 에러 메시지로 변환
      if (e.toString().contains('포트폴리오 ID가 필요') ||
          e.toString().contains('파일을 찾을 수 없습니다') ||
          e.toString().contains('지원하지 않는 파일 형식') ||
          e.toString().contains('파일 크기가 너무') ||
          e.toString().contains('최대') ||
          e.toString().contains('빈 파일') ||
          e.toString().contains('파일 인코딩에 실패')) {
        throw Exception(e.toString());
      }

      // Dio 에러는 기존 핸들러 사용
      if (e is DioException) {
        throw _handleDioError(e, '포트폴리오 수정');
      }

      // 기타 예상치 못한 에러
      throw Exception('이미지 처리 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  /// 포트폴리오 삭제
  /// DELETE /api/portfolios/{id}/delete
  Future<void> deletePortfolio(String id) async {
    try {
      await _dio.delete('$_baseUrl/$id/delete'); // /delete 추가
    } on DioException catch (e) {
      throw _handleDioError(e, '포트폴리오 삭제');
    }
  }

  /// 포트폴리오 좋아요/좋아요 취소
  /// POST /api/portfolios/{id}/like
  /// DELETE /api/portfolios/{id}/like
  Future<void> toggleLike(String portfolioId, bool isLiked) async {
    try {
      if (isLiked) {
        await _dio.post('$_baseUrl/$portfolioId/like');
      } else {
        await _dio.delete('$_baseUrl/$portfolioId/like');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, '좋아요 처리');
    }
  }

  /// 포트폴리오 이미지 업로드
  /// POST /api/portfolios/{id}/images
  Future<Map<String, dynamic>> uploadPortfolioImage(
      String portfolioId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '$_baseUrl/$portfolioId/images',
        data: formData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, '포트폴리오 이미지 업로드');
    }
  }

  /// DioException을 사용자 친화적인 에러 메시지로 변환
  Exception _handleDioError(DioException dioError, String operation) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('$operation 중 연결 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.');

      case DioExceptionType.badResponse:
        final statusCode = dioError.response?.statusCode;
        final errorMessage = _getErrorMessageFromResponse(dioError.response);

        switch (statusCode) {
          case 400:
            return Exception('$operation 요청이 잘못되었습니다: $errorMessage');
          case 401:
            return Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
          case 403:
            return Exception('$operation 권한이 없습니다.');
          case 404:
            return Exception('요청하신 포트폴리오를 찾을 수 없습니다.');
          case 500:
            return Exception('서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
          default:
            return Exception(
                '$operation 중 알 수 없는 오류가 발생했습니다 (코드: $statusCode)');
        }

      case DioExceptionType.connectionError:
        return Exception('네트워크에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.');

      case DioExceptionType.cancel:
        return Exception('$operation 요청이 취소되었습니다.');

      default:
        return Exception('$operation 중 예상치 못한 오류가 발생했습니다: ${dioError.message}');
    }
  }

  /// 서버 응답에서 에러 메시지 추출
  String _getErrorMessageFromResponse(Response? response) {
    if (response?.data != null) {
      if (response!.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return data['message'] ?? data['error'] ?? '알 수 없는 오류';
      }
    }
    return '알 수 없는 오류';
  }

  // PortfolioApiService 클래스에 추가할 메서드들

  /// 활성 카테고리 목록 조회
  /// GET /api/portfolio-categories
  Future<List<Map<String, dynamic>>> fetchActiveCategories() async {
    try {
      print('=== 활성 카테고리 조회 요청 ===');
      print('URL: /api/portfolio-categories');

      final response = await _dio.get('/api/portfolio-categories');

      print('=== 활성 카테고리 조회 응답 ===');
      print('상태 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('body')) {
          final body = responseData['body'];
          if (body is List) {
            return List<Map<String, dynamic>>.from(body);
          }
        }
      }

      // 직접 배열인 경우
      return List<Map<String, dynamic>>.from(responseData);
    } on DioException catch (e) {
      print('=== 활성 카테고리 조회 에러 ===');
      print('에러 타입: ${e.type}');
      print('상태 코드: ${e.response?.statusCode}');
      throw _handleDioError(e, '카테고리 목록 조회');
    }
  }

  /// 포트폴리오 검색 (키워드 + 카테고리 필터)
  /// GET /api/portfolios/search?keyword={keyword}&categoryIds={categoryIds}&page={page}&size={size}
  Future<PaginatedResponse<Map<String, dynamic>>> searchPortfolios({
    String? keyword,
    List<int>? categoryIds,
    int page = 0,
    int size = 10,
  }) async {
    try {
      print('=== 포트폴리오 검색 요청 ===');
      print('키워드: $keyword');
      print('카테고리 IDs: $categoryIds');
      print('페이지: $page, 사이즈: $size');

      final queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (keyword != null && keyword.isNotEmpty) {
        queryParameters['keyword'] = keyword;
      }

      if (categoryIds != null && categoryIds.isNotEmpty) {
        queryParameters['categoryIds'] = categoryIds.join(',');
      }

      final response = await _dio.get(
        '/api/portfolios/search',
        queryParameters: queryParameters,
      );

      print('=== 포트폴리오 검색 응답 ===');
      print('상태 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('body')) {
          final body = responseData['body'];

          if (body is Map<String, dynamic> && body.containsKey('content')) {
            // 페이징된 응답: Page<T> 구조
            return PaginatedResponse<Map<String, dynamic>>(
              content: List<Map<String, dynamic>>.from(body['content']),
              page: body['number'] ?? page,
              size: body['size'] ?? size,
              totalElements: body['totalElements'] ?? 0,
              totalPages: body['totalPages'] ?? 0,
              isLast: body['last'] ?? true,
              hasNext: !(body['last'] ?? true),
            );
          } else if (body is List) {
            // 직접 배열 응답 (페이징 정보 없음)
            final content = List<Map<String, dynamic>>.from(body);
            return PaginatedResponse<Map<String, dynamic>>(
              content: content,
              page: page,
              size: content.length,
              totalElements: content.length,
              totalPages: 1,
              isLast: true,
              hasNext: false,
            );
          }
        }
      }

      throw Exception('예상하지 못한 응답 구조');
    } on DioException catch (e) {
      print('=== 포트폴리오 검색 에러 ===');
      print('에러 타입: ${e.type}');
      print('상태 코드: ${e.response?.statusCode}');
      throw _handleDioError(e, '포트폴리오 검색');
    }
  }

  // ========== PortfolioApiService에 추가할 카테고리 매핑 메서드 ==========

  /// 카테고리명을 ID로 변환하는 임시 매핑 테이블
  /// 실제로는 서버에서 카테고리 목록 API를 호출해야 함
  Map<String, int> _getCategoryMapping() {
    return {
      '웨딩촬영': 1,
      '인물촬영': 2,
      '가족사진': 3,
      '커플촬영': 4,
    };
  }

  /// 카테고리명 배열을 ID 배열로 변환 (서버 API 사용)
  Future<List<int>> _convertCategoriesToIds(List<String> categoryNames) async {
    final mapping = await fetchCategoryMapping();
    List<int> categoryIds = [];

    for (String categoryName in categoryNames) {
      final id = mapping[categoryName];
      if (id != null) {
        categoryIds.add(id);
        print('카테고리 매핑: $categoryName -> $id');
      } else {
        print('경고: 알 수 없는 카테고리 - $categoryName');
        // 기본값 처리: 첫 번째 카테고리 ID 사용 또는 스킵
        if (mapping.isNotEmpty) {
          final defaultId = mapping.values.first;
          categoryIds.add(defaultId);
          print('기본 카테고리 ID 사용: $defaultId');
        }
      }
    }

    return categoryIds;
  }

  /// 서버에서 실제 카테고리 목록을 가져오는 메서드
  Future<Map<String, int>> fetchCategoryMapping() async {
    try {
      print('=== 카테고리 목록 조회 요청 ===');
      final response = await _dio.get('/api/portfolio-categories');

      print('=== 카테고리 목록 조회 응답 ===');
      print('상태 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');

      Map<String, int> mapping = {};

      // 서버 응답 구조에 맞게 파싱
      final responseData = response.data;
      List categories;

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('body')) {
        categories = responseData['body'] as List;
      } else {
        categories = responseData as List;
      }

      for (var category in categories) {
        final id = category['categoryId'] ?? category['id'];
        final name = category['categoryName'] ?? category['name'];
        if (id != null && name != null) {
          mapping[name] = id;
          print('카테고리 매핑: $name -> $id');
        }
      }

      print('총 ${mapping.length}개 카테고리 매핑 완료');
      return mapping;
    } catch (e) {
      print('카테고리 목록 조회 실패, 기본 매핑 사용: $e');
      return _getCategoryMapping();
    }
  }
}
