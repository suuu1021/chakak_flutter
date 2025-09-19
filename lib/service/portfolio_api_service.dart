// lib/services/api/portfolio_api_service.dart

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
      final response = await _dio.get('$_baseUrl/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
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
}
