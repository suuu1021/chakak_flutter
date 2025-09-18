// lib/services/api/portfolio_api_service.dart

import 'package:dio/dio.dart';

/// Portfolio 관련 HTTP API 호출을 담당하는 서비스 클래스
class PortfolioApiService {
  final Dio _dio;
  static const String _baseUrl = '/api/portfolios';

  PortfolioApiService(this._dio);

  /// 모든 포트폴리오 목록 조회
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
  /// GET /api/portfolios/photographer/{photographerId}
  Future<List<Map<String, dynamic>>> fetchPortfoliosByPhotographer(
      String photographerId) async {
    try {
      final response = await _dio.get('$_baseUrl/photographer/$photographerId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, '사진작가 포트폴리오 조회');
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
  /// POST /api/portfolios
  Future<Map<String, dynamic>> createPortfolio(
      Map<String, dynamic> portfolioData) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: portfolioData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, '포트폴리오 생성');
    }
  }

  /// 포트폴리오 수정
  /// PUT /api/portfolios/{id}
  Future<Map<String, dynamic>> updatePortfolio(
      String id, Map<String, dynamic> portfolioData) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/$id',
        data: portfolioData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, '포트폴리오 수정');
    }
  }

  /// 포트폴리오 삭제
  /// DELETE /api/portfolios/{id}
  Future<void> deletePortfolio(String id) async {
    try {
      await _dio.delete('$_baseUrl/$id');
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
}
