// portfolio_repository.dart - 페이징 메서드 추가

import '../../../service/portfolio_api_service.dart';
import '../portfolio.dart';

// 페이징 결과 클래스 추가
class PaginatedPortfolioResult {
  final List<Portfolio> portfolios;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool hasNext;
  final bool isLast;

  const PaginatedPortfolioResult({
    required this.portfolios,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.hasNext,
    required this.isLast,
  });
}

/// Portfolio 데이터 액세스를 위한 Repository 인터페이스
abstract class PortfolioRepository {
  /// 모든 포트폴리오 목록 조회
  Future<List<Portfolio>> getPortfolios();

  /// 페이징된 포트폴리오 목록 조회 - 새로 추가
  Future<PaginatedPortfolioResult> getPortfoliosPaginated({
    int page = 0,
    int size = 10,
  });

  /// 특정 포트폴리오 조회
  Future<Portfolio> getPortfolioById(String id);

  /// 특정 사진작가의 포트폴리오 목록 조회
  Future<List<Portfolio>> getPortfoliosByPhotographerId(String photographerId);

  /// 카테고리별 포트폴리오 조회
  Future<List<Portfolio>> getPortfoliosByCategory(String category);

  /// 인기 포트폴리오 조회 (좋아요 순)
  Future<List<Portfolio>> getPopularPortfolios({int limit = 10});

  /// 포트폴리오 생성
  Future<Portfolio> createPortfolio(Portfolio portfolio);

  /// 포트폴리오 수정
  Future<Portfolio> updatePortfolio(String id, Portfolio portfolio);

  /// 포트폴리오 삭제
  Future<void> deletePortfolio(String id);

  /// 포트폴리오 좋아요/좋아요 취소
  Future<void> toggleLike(String portfolioId, bool isLiked);

  Future<PaginatedPortfolioResult> getPortfoliosByPhotographerPaginated({
    required String photographerId,
    int page = 0,
    int size = 10,
  });
}

/// Portfolio Repository 구현체
class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioApiService _apiService;

  PortfolioRepositoryImpl(this._apiService);

  @override
  Future<List<Portfolio>> getPortfolios() async {
    try {
      final response = await _apiService.fetchPortfolios();
      return response.map((json) => Portfolio.fromJson(json)).toList();
    } catch (e) {
      throw Exception('포트폴리오 목록을 불러오는데 실패했습니다: $e');
    }
  }

  @override
  Future<PaginatedPortfolioResult> getPortfoliosPaginated({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiService.fetchPortfoliosPaginated(
        page: page,
        size: size,
      );

      final portfolios =
          response.content.map((json) => Portfolio.fromJson(json)).toList();

      return PaginatedPortfolioResult(
        portfolios: portfolios,
        currentPage: response.page,
        totalPages: response.totalPages,
        totalElements: response.totalElements,
        hasNext: response.hasNext,
        isLast: response.isLast,
      );
    } catch (e) {
      throw Exception('페이징된 포트폴리오 목록을 불러오는데 실패했습니다: $e');
    }
  }

  @override
  Future<Portfolio> getPortfolioById(String id) async {
    try {
      final response = await _apiService.fetchPortfolioById(id);
      return Portfolio.fromJson(response);
    } catch (e) {
      throw Exception('포트폴리오 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<List<Portfolio>> getPortfoliosByPhotographerId(
      String photographerId) async {
    try {
      final response =
          await _apiService.fetchPortfoliosByPhotographer(photographerId);
      return response.map((json) => Portfolio.fromJson(json)).toList();
    } catch (e) {
      throw Exception('사진작가 포트폴리오 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<PaginatedPortfolioResult> getPortfoliosByPhotographerPaginated({
    required String photographerId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiService.fetchPortfoliosByPhotographerPaginated(
        photographerId: photographerId,
        page: page,
        size: size,
      );

      final portfolios =
          response.content.map((json) => Portfolio.fromJson(json)).toList();

      return PaginatedPortfolioResult(
        portfolios: portfolios,
        currentPage: response.page,
        totalPages: response.totalPages,
        totalElements: response.totalElements,
        hasNext: response.hasNext,
        isLast: response.isLast,
      );
    } catch (e) {
      throw Exception('작가별 페이징 포트폴리오 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<List<Portfolio>> getPortfoliosByCategory(String category) async {
    try {
      final response = await _apiService.fetchPortfoliosByCategory(category);
      return response.map((json) => Portfolio.fromJson(json)).toList();
    } catch (e) {
      throw Exception('카테고리별 포트폴리오 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<List<Portfolio>> getPopularPortfolios({int limit = 10}) async {
    try {
      final response = await _apiService.fetchPopularPortfolios(limit: limit);
      return response.map((json) => Portfolio.fromJson(json)).toList();
    } catch (e) {
      throw Exception('인기 포트폴리오 조회에 실패했습니다: $e');
    }
  }

  @override
  Future<Portfolio> createPortfolio(Portfolio portfolio) async {
    try {
      final response = await _apiService.createPortfolio(portfolio.toJson());
      return Portfolio.fromJson(response);
    } catch (e) {
      throw Exception('포트폴리오 생성에 실패했습니다: $e');
    }
  }

  @override
  Future<Portfolio> updatePortfolio(String id, Portfolio portfolio) async {
    try {
      print('=== 포트폴리오 수정 요청 ===');
      print('ID: $id');
      print('요청 데이터: ${portfolio.toJson()}');

      final response =
          await _apiService.updatePortfolio(id, portfolio.toJson());

      print('=== 포트폴리오 수정 응답 ===');
      print('응답 데이터: $response');
      print('thumbnailUrl 필드: ${response['thumbnailUrl']}');
      print('mainImageUrl 필드: ${response['mainImageUrl']}');

      final updatedPortfolio = Portfolio.fromJson(response);

      print('=== 파싱된 포트폴리오 ===');
      print('제목: ${updatedPortfolio.title}');
      print('썸네일: ${updatedPortfolio.thumbnailUrl}');
      print('이미지들: ${updatedPortfolio.imageUrls}');

      return updatedPortfolio;
    } catch (e) {
      throw Exception('포트폴리오 수정에 실패했습니다: $e');
    }
  }

  @override
  Future<void> deletePortfolio(String id) async {
    try {
      await _apiService.deletePortfolio(id);
    } catch (e) {
      throw Exception('포트폴리오 삭제에 실패했습니다: $e');
    }
  }

  @override
  Future<void> toggleLike(String portfolioId, bool isLiked) async {
    try {
      await _apiService.toggleLike(portfolioId, isLiked);
    } catch (e) {
      throw Exception('좋아요 처리에 실패했습니다: $e');
    }
  }
}
