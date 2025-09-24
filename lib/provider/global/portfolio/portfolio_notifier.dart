// lib/providers/portfolio_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/portfolio.dart';
import 'package:dio/dio.dart';

import '../../../data/models/repositories/portfolio_repository.dart';
import '../../../service/portfolio_api_service.dart';
import '../../auth/session_provider.dart';

// 창고 Data
// portfolio_provider.dart - PortfolioState 수정

class PortfolioState {
  final List<Portfolio> portfolios;
  final bool isLoading;
  final bool isLoadingMore; // 추가 로딩 상태
  final String? errorMessage;
  final Portfolio? selectedPortfolio;

  // 페이징 정보 추가
  final int currentPage;
  final bool hasNextPage;
  final int totalElements;

  const PortfolioState({
    required this.portfolios,
    required this.isLoading,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedPortfolio,
    this.currentPage = 0,
    this.hasNextPage = true,
    this.totalElements = 0,
  });

  PortfolioState copyWith({
    List<Portfolio>? portfolios,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    Portfolio? selectedPortfolio,
    int? currentPage,
    bool? hasNextPage,
    int? totalElements,
  }) {
    return PortfolioState(
      portfolios: portfolios ?? this.portfolios,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      selectedPortfolio: selectedPortfolio ?? this.selectedPortfolio,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      totalElements: totalElements ?? this.totalElements,
    );
  }
}

// 창고 Manual
class PortfolioNotifier extends Notifier<PortfolioState> {
  late PortfolioRepository _portfolioRepository;
  static const int _pageSize = 10; // 한 페이지당 아이템 수

  @override
  PortfolioState build() {
    // Dio 및 ApiService 초기화
    final dio = Dio();
    dio.options.baseUrl = 'http://10.0.2.2:8080';

    // 세션에서 JWT 토큰 가져와서 헤더에 추가
    final session = ref.watch(sessionProvider);

    if (kDebugMode) {
      print('[PortfolioProvider] 세션 상태 확인:');
      print('  - jwtToken: ${session.jwtToken}');
      print('  - userId: ${session.userId}');
      print('  - userNickname: ${session.userNickname}');
      print('  - isLogin: ${session.isLogin}');
    }

    if (session.jwtToken != null && session.isLogin) {
      dio.options.headers['Authorization'] = 'Bearer ${session.jwtToken}';
      if (kDebugMode) {
        print('[PortfolioProvider] JWT 토큰 헤더 추가됨');
      }
    } else {
      if (kDebugMode) {
        print('[PortfolioProvider] 경고: JWT 토큰이 없거나 로그인되지 않음');
      }
    }

    final apiService = PortfolioApiService(dio);
    _portfolioRepository = PortfolioRepositoryImpl(apiService);

    return const PortfolioState(
      portfolios: [],
      isLoading: true,
    );
  }

  /// 첫 페이지 포트폴리오 로드 (새로고침)
  Future<void> loadPortfolios() async {
    if (kDebugMode) {
      print('포트폴리오 첫 페이지 로딩 시작');
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 0,
      hasNextPage: true,
    );

    try {
      final paginatedResult = await _portfolioRepository.getPortfoliosPaginated(
        page: 0,
        size: _pageSize,
      );

      if (kDebugMode) {
        print('포트폴리오 첫 페이지 ${paginatedResult.portfolios.length}개 로드 완료');
        print(
            '전체: ${paginatedResult.totalElements}개, 다음 페이지: ${paginatedResult.hasNext}');
      }

      state = state.copyWith(
        portfolios: paginatedResult.portfolios,
        isLoading: false,
        currentPage: paginatedResult.currentPage,
        hasNextPage: paginatedResult.hasNext,
        totalElements: paginatedResult.totalElements,
      );
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 첫 페이지 로딩 실패: $e');
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 다음 페이지 포트폴리오 로드 (무한 스크롤)
  Future<void> loadMorePortfolios() async {
    // 이미 로딩 중이거나 더 이상 페이지가 없으면 중단
    if (state.isLoadingMore || !state.hasNextPage) {
      if (kDebugMode) {
        print(
            '추가 로딩 중단: isLoadingMore=${state.isLoadingMore}, hasNextPage=${state.hasNextPage}');
      }
      return;
    }

    final nextPage = state.currentPage + 1;

    if (kDebugMode) {
      print('포트폴리오 다음 페이지($nextPage) 로딩 시작');
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final paginatedResult = await _portfolioRepository.getPortfoliosPaginated(
        page: nextPage,
        size: _pageSize,
      );

      if (kDebugMode) {
        print('포트폴리오 다음 페이지 ${paginatedResult.portfolios.length}개 로드 완료');
        print(
            '페이지: ${paginatedResult.currentPage}, 다음 페이지: ${paginatedResult.hasNext}');
      }

      // 기존 목록에 새 데이터 추가
      final updatedPortfolios = [
        ...state.portfolios,
        ...paginatedResult.portfolios,
      ];

      state = state.copyWith(
        portfolios: updatedPortfolios,
        isLoadingMore: false,
        currentPage: paginatedResult.currentPage,
        hasNextPage: paginatedResult.hasNext,
        totalElements: paginatedResult.totalElements,
      );
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 다음 페이지 로딩 실패: $e');
      }

      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 새로고침 (첫 페이지부터 다시 로드)
  Future<void> refreshPortfolios() async {
    if (kDebugMode) {
      print('포트폴리오 새로고침');
    }

    await loadPortfolios();
  }

  /// 특정 사진작가의 포트폴리오 첫 페이지 로드
  Future<void> loadPortfoliosByPhotographer(String photographerId) async {
    if (kDebugMode) {
      print('사진작가 $photographerId 포트폴리오 로딩 시작');
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 0,
      hasNextPage: true,
    );

    try {
      final paginatedResult =
          await _portfolioRepository.getPortfoliosByPhotographerPaginated(
        photographerId: photographerId,
        page: 0,
        size: _pageSize,
      );

      if (kDebugMode) {
        print('사진작가 포트폴리오 ${paginatedResult.portfolios.length}개 로드 완료');
        print(
            '전체: ${paginatedResult.totalElements}개, 다음 페이지: ${paginatedResult.hasNext}');
      }

      state = state.copyWith(
        portfolios: paginatedResult.portfolios,
        isLoading: false,
        currentPage: paginatedResult.currentPage,
        hasNextPage: paginatedResult.hasNext,
        totalElements: paginatedResult.totalElements,
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

  /// 특정 사진작가의 다음 페이지 포트폴리오 로드 (무한 스크롤)
  Future<void> loadMorePortfoliosByPhotographer(String photographerId) async {
    if (state.isLoadingMore || !state.hasNextPage) {
      return;
    }

    final nextPage = state.currentPage + 1;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final paginatedResult =
          await _portfolioRepository.getPortfoliosByPhotographerPaginated(
        photographerId: photographerId,
        page: nextPage,
        size: _pageSize,
      );

      final updatedPortfolios = [
        ...state.portfolios,
        ...paginatedResult.portfolios,
      ];

      state = state.copyWith(
        portfolios: updatedPortfolios,
        isLoadingMore: false,
        currentPage: paginatedResult.currentPage,
        hasNextPage: paginatedResult.hasNext,
        totalElements: paginatedResult.totalElements,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
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

  /// 포트폴리오 생성 (파일 업로드 포함)
  Future<Portfolio?> createPortfolioWithFiles({
    required String title,
    required String description,
    required List<String> categories,
    required int photographerId,
    required List<String> imagePaths,
  }) async {
    if (kDebugMode) {
      print('파일 업로드 포트폴리오 생성 시작: $title');
      print('이미지 파일 개수: ${imagePaths.length}');
    }

    try {
      // 1. API를 통해 포트폴리오 생성 (반환된 객체는 불완전할 수 있음)
      final partiallyCreatedPortfolio =
          await _portfolioRepository.createPortfolioWithFiles(
        title: title,
        description: description,
        categories: categories,
        photographerId: photographerId,
        imageData: imagePaths,
      );

      if (kDebugMode) {
        print(
            '포트폴리오 1차 생성 완료: ${partiallyCreatedPortfolio.title}, ID: ${partiallyCreatedPortfolio.id}');
      }

      // 2. 생성된 포트폴리오의 ID를 사용하여 완전한 정보 다시 조회
      await selectPortfolio(partiallyCreatedPortfolio.id);
      final createdPortfolio = state.selectedPortfolio;

      if (createdPortfolio == null) {
        throw Exception("생성 후 포트폴리오를 다시 조회하는 데 실패했습니다.");
      }

      if (kDebugMode) {
        print('포트폴리오 최종 조회 완료: ${createdPortfolio.title}');
        print('이미지 URL 개수: ${createdPortfolio.imageUrls.length}');
      }

      // 3. 전체 포트폴리오 목록 새로고침
      await loadPortfolios();

      // 4. 완전한 포트폴리오 객체 반환
      return createdPortfolio;
    } catch (e) {
      if (kDebugMode) {
        print('파일 업로드 포트폴리오 생성 실패: $e');
      }

      state = state.copyWith(errorMessage: e.toString());
      return null;
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

      // selectedPortfolio도 함께 업데이트
      Portfolio? updatedSelectedPortfolio = state.selectedPortfolio;
      if (state.selectedPortfolio?.id == id) {
        updatedSelectedPortfolio = updatedPortfolio;
      }

      state = state.copyWith(
        portfolios: updatedList,
        selectedPortfolio: updatedSelectedPortfolio, // 추가
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('포트폴리오 수정 실패: $e');
      }

      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// 포트폴리오 수정 (파일 업로드 포함)
  Future<bool> updatePortfolioWithFiles({
    required String portfolioId,
    required String title,
    required String description,
    required List<String> categories,
    required List<String> existingImageUrls,
    required List<String> newImagePaths,
  }) async {
    if (kDebugMode) {
      print('=== [Provider] 포트폴리오 수정 시작 ===');
      print('포트폴리오 ID: $portfolioId');
      print('제목: $title');
      print('설명 길이: ${description.length}');
      print('카테고리 개수: ${categories.length}');
      print('이미지 경로 개수: ${newImagePaths.length}');
    }

    try {
      final updatedPortfolio =
          await _portfolioRepository.updatePortfolioWithFiles(
        portfolioId: portfolioId,
        title: title,
        description: description,
        categories: categories,
        existingImageUrls: existingImageUrls,
        newImagePaths: newImagePaths,
      );

      if (kDebugMode) {
        print('파일 업로드 포트폴리오 수정 완료: ${updatedPortfolio.title}');
      }

      // 기존 목록에서 해당 포트폴리오 업데이트
      final updatedList = state.portfolios.map((p) {
        return p.id == portfolioId ? updatedPortfolio : p;
      }).toList();

      // selectedPortfolio도 함께 업데이트
      Portfolio? updatedSelectedPortfolio = state.selectedPortfolio;
      if (state.selectedPortfolio?.id == portfolioId) {
        updatedSelectedPortfolio = updatedPortfolio;
      }

      state = state.copyWith(
        portfolios: updatedList,
        selectedPortfolio: updatedSelectedPortfolio,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('=== [Provider] 포트폴리오 수정 실패 ===');
        print('에러 타입: ${e.runtimeType}');
        print('에러 메시지: $e');
        print('스택 트레이스: ${StackTrace.current}');
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
