// lib/providers/portfolio_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/portfolio.dart';
import '../../../data/models/repositories/portfolio_repository.dart';
import '../../../service/portfolio_api_service.dart';
import 'package:dio/dio.dart';

// 창고 Data
class PortfolioState {
  final List<Portfolio> portfolios;
  final bool isLoading;
  final String? errorMessage;
  final Portfolio? selectedPortfolio;

  const PortfolioState({
    required this.portfolios,
    required this.isLoading,
    this.errorMessage,
    this.selectedPortfolio,
  });

  PortfolioState copyWith({
    List<Portfolio>? portfolios,
    bool? isLoading,
    String? errorMessage,
    Portfolio? selectedPortfolio,
  }) {
    return PortfolioState(
      portfolios: portfolios ?? this.portfolios,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedPortfolio: selectedPortfolio ?? this.selectedPortfolio,
    );
  }
}

// 창고 Manual
class PortfolioNotifier extends Notifier<PortfolioState> {
  late PortfolioRepository _portfolioRepository;

  @override
  PortfolioState build() {
    // Dio 및 ApiService 초기화
    final dio = Dio();
    dio.options.baseUrl = 'http://10.0.2.2:8080'; // Android 에뮬레이터용

    final apiService = PortfolioApiService(dio);
    _portfolioRepository = PortfolioRepositoryImpl(apiService);

    // 초기 데이터 로드를 비동기로 처리
    Future.microtask(() => loadPortfolios());

    return const PortfolioState(
      portfolios: [],
      isLoading: true,
    );
  }

  /// 모든 포트폴리오 목록 로드
  Future<void> loadPortfolios() async {
    if (kDebugMode) {
      print('포트폴리오 목록 로딩 시작');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final portfolios = await _portfolioRepository.getPortfolios();

      if (kDebugMode) {
        print('포트폴리오 ${portfolios.length}개 로드 완료');
      }

      state = state.copyWith(
        portfolios: portfolios,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 로딩 실패: $e');
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 특정 사진작가의 포트폴리오 로드
  Future<void> loadPortfoliosByPhotographer(String photographerId) async {
    if (kDebugMode) {
      print('사진작가 $photographerId 포트폴리오 로딩 시작');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final portfolios = await _portfolioRepository
          .getPortfoliosByPhotographerId(photographerId);

      if (kDebugMode) {
        print('사진작가 포트폴리오 ${portfolios.length}개 로드 완료');
      }

      state = state.copyWith(
        portfolios: portfolios,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('사진작가 포트폴리오 로딩 실패: $e');
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 카테고리별 포트폴리오 로드
  Future<void> loadPortfoliosByCategory(String category) async {
    if (kDebugMode) {
      print('카테고리 $category 포트폴리오 로딩 시작');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final portfolios =
          await _portfolioRepository.getPortfoliosByCategory(category);

      if (kDebugMode) {
        print('카테고리 포트폴리오 ${portfolios.length}개 로드 완료');
      }

      state = state.copyWith(
        portfolios: portfolios,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('카테고리 포트폴리오 로딩 실패: $e');
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 인기 포트폴리오 로드
  Future<void> loadPopularPortfolios({int limit = 10}) async {
    if (kDebugMode) {
      print('인기 포트폴리오 로딩 시작 (limit: $limit)');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final portfolios =
          await _portfolioRepository.getPopularPortfolios(limit: limit);

      if (kDebugMode) {
        print('인기 포트폴리오 ${portfolios.length}개 로드 완료');
      }

      state = state.copyWith(
        portfolios: portfolios,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('인기 포트폴리오 로딩 실패: $e');
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 특정 포트폴리오 선택
  Future<void> selectPortfolio(String portfolioId) async {
    if (kDebugMode) {
      print('포트폴리오 $portfolioId 선택');
    }

    try {
      final portfolio =
          await _portfolioRepository.getPortfolioById(portfolioId);

      if (kDebugMode) {
        print('포트폴리오 선택 완료: ${portfolio.title}');
      }

      state = state.copyWith(selectedPortfolio: portfolio);
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 선택 실패: $e');
      }

      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 포트폴리오 생성
  Future<bool> createPortfolio(Portfolio portfolio) async {
    if (kDebugMode) {
      print('포트폴리오 생성 시작: ${portfolio.title}');
    }

    try {
      final createdPortfolio =
          await _portfolioRepository.createPortfolio(portfolio);

      if (kDebugMode) {
        print('포트폴리오 생성 완료: ${createdPortfolio.title}');
      }

      // 기존 목록에 새 포트폴리오 추가
      state = state.copyWith(
        portfolios: [...state.portfolios, createdPortfolio],
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 생성 실패: $e');
      }

      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// 포트폴리오 수정
  Future<bool> updatePortfolio(String id, Portfolio portfolio) async {
    if (kDebugMode) {
      print('포트폴리오 수정 시작: $id');
    }

    try {
      final updatedPortfolio =
          await _portfolioRepository.updatePortfolio(id, portfolio);

      if (kDebugMode) {
        print('포트폴리오 수정 완료: ${updatedPortfolio.title}');
      }

      // 기존 목록에서 해당 포트폴리오 업데이트
      final updatedList = state.portfolios.map((p) {
        return p.id == id ? updatedPortfolio : p;
      }).toList();

      state = state.copyWith(portfolios: updatedList);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 수정 실패: $e');
      }

      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// 포트폴리오 삭제
  Future<bool> deletePortfolio(String id) async {
    if (kDebugMode) {
      print('포트폴리오 삭제 시작: $id');
    }

    try {
      await _portfolioRepository.deletePortfolio(id);

      if (kDebugMode) {
        print('포트폴리오 삭제 완료: $id');
      }

      // 기존 목록에서 해당 포트폴리오 제거
      final updatedList = state.portfolios.where((p) => p.id != id).toList();

      state = state.copyWith(portfolios: updatedList);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 삭제 실패: $e');
      }

      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// 좋아요 토글
  Future<void> toggleLike(String portfolioId) async {
    if (kDebugMode) {
      print('포트폴리오 $portfolioId 좋아요 토글');
    }

    final portfolio = state.portfolios.firstWhere((p) => p.id == portfolioId);
    final isCurrentlyLiked = false; // TODO: 실제 좋아요 상태 확인 로직 필요

    try {
      await _portfolioRepository.toggleLike(portfolioId, !isCurrentlyLiked);

      // UI에서 즉시 반영 (옵티미스틱 업데이트)
      final updatedList = state.portfolios.map((p) {
        if (p.id == portfolioId) {
          return p.copyWith(
            likes: isCurrentlyLiked ? p.likes - 1 : p.likes + 1,
          );
        }
        return p;
      }).toList();

      state = state.copyWith(portfolios: updatedList);

      if (kDebugMode) {
        print('포트폴리오 좋아요 토글 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 좋아요 토글 실패: $e');
      }

      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// 창고 Install
final portfolioProvider = NotifierProvider<PortfolioNotifier, PortfolioState>(
  () => PortfolioNotifier(),
);
