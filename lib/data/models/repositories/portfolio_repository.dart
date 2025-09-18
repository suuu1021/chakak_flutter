// lib/data/repositories/portfolio_repository.dart

import '../../../service/portfolio_api_service.dart';
import '../portfolio.dart';

/// Portfolio 데이터 액세스를 위한 Repository 인터페이스
abstract class PortfolioRepository {
  /// 모든 포트폴리오 목록 조회
  Future<List<Portfolio>> getPortfolios();

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
      final response =
          await _apiService.updatePortfolio(id, portfolio.toJson());
      return Portfolio.fromJson(response);
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
