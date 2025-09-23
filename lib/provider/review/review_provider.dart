// D:/flutter/chakak_flutter/lib/provider/review/review_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core DioProvider
// 실제 dio_provider.dart 파일 경로에 맞게 수정해주세요.
// 예: import 'package:chakak_flutter/provider/core/dio_provider.dart';
import '../core/dio_provider.dart';

// Repositories
import '../../data/models/repositories/review_repository.dart';

// DTOs
import '../../data/dtos/review/review_status_dto.dart';
import '../../data/dtos/review/review_dto.dart';
import '../../data/dtos/paged_response_dto.dart';

// 1. ReviewRepositoryProvider (변경 없음)
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewRepository(dio);
});

// --- Review Status (특정 서비스의 리뷰 통계) ---

// 2. 리뷰 통계 조회 상태 Enum
enum ReviewServiceFetchStatus {
  initial,
  loading,
  success,
  error,
}

// 3. 리뷰 통계 상태 클래스
class ReviewServiceStatusState {
  final ReviewServiceFetchStatus status;
  final ReviewStatusDto? data;
  final String? errorMessage;
  final int? currentServiceId;

  const ReviewServiceStatusState({
    this.status = ReviewServiceFetchStatus.initial,
    this.data,
    this.errorMessage,
    this.currentServiceId,
  });

  ReviewServiceStatusState copyWith({
    ReviewServiceFetchStatus? status,
    ReviewStatusDto? data,
    String? errorMessage,
    int? currentServiceId,
    bool clearData = false,
    bool clearErrorMessage = false,
  }) {
    return ReviewServiceStatusState(
      status: status ?? this.status,
      data: clearData ? null : data ?? this.data,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      currentServiceId: currentServiceId ?? this.currentServiceId,
    );
  }
}

// 4. 리뷰 통계 Notifier
class ReviewServiceStatusNotifier extends Notifier<ReviewServiceStatusState> {
  @override
  ReviewServiceStatusState build() {
    return const ReviewServiceStatusState();
  }

  Future<void> fetchStatus(int serviceId) async {
    if (state.status == ReviewServiceFetchStatus.loading &&
        state.currentServiceId == serviceId) return;

    final repo = ref.read(reviewRepositoryProvider);
    state = state.copyWith(
        status: ReviewServiceFetchStatus.loading,
        currentServiceId: serviceId,
        clearData: true,
        clearErrorMessage: true);

    try {
      final statusData = await repo.getReviewStatus(serviceId);
      // if (!mounted) return; // 제거됨
      state = state.copyWith(
          status: ReviewServiceFetchStatus.success, data: statusData);
    } catch (e) {
      // if (!mounted) return; // 제거됨
      state = state.copyWith(
          status: ReviewServiceFetchStatus.error, errorMessage: e.toString());
    }
  }

  void resetState() {
    state = const ReviewServiceStatusState();
  }
}

// 5. 리뷰 통계 Provider 정의
final reviewStatusProvider =
    NotifierProvider<ReviewServiceStatusNotifier, ReviewServiceStatusState>(
  ReviewServiceStatusNotifier.new,
);

// --- Reviews List (특정 서비스의 리뷰 목록, 페이지네이션 포함) ---

// 6. 리뷰 목록 조회 상태 Enum
enum ReviewsListFetchStatus {
  initial,
  loadingFirstPage,
  loadingMore,
  success,
  error,
  allLoaded,
}

// 7. 리뷰 목록 상태 클래스
class ReviewsListState {
  final ReviewsListFetchStatus status;
  final List<ReviewDto> reviews;
  final int currentPage;
  final String? errorMessage;
  final bool canLoadMore;
  final int? currentServiceId;
  final String? currentSortBy;
  final String? currentSortDir;

  const ReviewsListState({
    this.status = ReviewsListFetchStatus.initial,
    this.reviews = const [],
    this.currentPage = 0,
    this.errorMessage,
    this.canLoadMore = true,
    this.currentServiceId,
    this.currentSortBy,
    this.currentSortDir,
  });

  ReviewsListState copyWith({
    ReviewsListFetchStatus? status,
    List<ReviewDto>? reviews,
    int? currentPage,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? canLoadMore,
    int? currentServiceId,
    String? currentSortBy,
    String? currentSortDir,
    bool clearReviews = false,
  }) {
    return ReviewsListState(
      status: status ?? this.status,
      reviews: clearReviews ? [] : reviews ?? this.reviews,
      currentPage: currentPage ?? this.currentPage,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      currentServiceId: currentServiceId ?? this.currentServiceId,
      currentSortBy: currentSortBy ?? this.currentSortBy,
      currentSortDir: currentSortDir ?? this.currentSortDir,
    );
  }
}

// 8. 리뷰 목록 Notifier
class ReviewsListNotifier extends Notifier<ReviewsListState> {
  final int _pageSize = 10;

  @override
  ReviewsListState build() {
    return const ReviewsListState();
  }

  Future<void> loadFirstPage(int serviceId,
      {String? sortBy, String? sortDir}) async {
    if (state.status == ReviewsListFetchStatus.loadingFirstPage &&
        state.currentServiceId == serviceId &&
        state.currentSortBy == sortBy &&
        state.currentSortDir == sortDir) {
      return;
    }

    state = state.copyWith(
      status: ReviewsListFetchStatus.loadingFirstPage,
      currentServiceId: serviceId,
      currentSortBy: sortBy,
      currentSortDir: sortDir,
      clearReviews: true,
      currentPage: 0,
      canLoadMore: true,
      clearErrorMessage: true,
    );

    try {
      final repo = ref.read(reviewRepositoryProvider);
      final pagedResponse = await repo.getReviews(
        serviceId,
        page: 0,
        size: _pageSize,
        sortBy: state.currentSortBy,
        sortDir: state.currentSortDir,
      );

      // if (!mounted) return; // 제거됨
      state = state.copyWith(
        status: ReviewsListFetchStatus.success,
        reviews: pagedResponse.content,
        currentPage: pagedResponse.number,
        canLoadMore: !pagedResponse.last,
      );
      if (pagedResponse.last) {
        state = state.copyWith(status: ReviewsListFetchStatus.allLoaded);
      }
    } catch (e) {
      // if (!mounted) return; // 제거됨
      state = state.copyWith(
        status: ReviewsListFetchStatus.error,
        errorMessage: e.toString(),
        clearReviews: true,
        canLoadMore: false,
      );
    }
  }

  Future<void> loadMoreReviews() async {
    if (state.currentServiceId == null ||
        state.status == ReviewsListFetchStatus.loadingMore ||
        state.status == ReviewsListFetchStatus.loadingFirstPage ||
        !state.canLoadMore) {
      return;
    }

    state = state.copyWith(
        status: ReviewsListFetchStatus.loadingMore, clearErrorMessage: true);

    try {
      final repo = ref.read(reviewRepositoryProvider);
      final nextPage = state.currentPage + 1;
      final pagedResponse = await repo.getReviews(
        state.currentServiceId!,
        page: nextPage,
        size: _pageSize,
        sortBy: state.currentSortBy,
        sortDir: state.currentSortDir,
      );

      // if (!mounted) return; // 제거됨
      final newReviews = [...state.reviews, ...pagedResponse.content];
      state = state.copyWith(
        status: ReviewsListFetchStatus.success,
        reviews: newReviews,
        currentPage: pagedResponse.number,
        canLoadMore: !pagedResponse.last,
      );
      if (pagedResponse.last) {
        state = state.copyWith(status: ReviewsListFetchStatus.allLoaded);
      }
    } catch (e) {
      // if (!mounted) return; // 제거됨
      state = state.copyWith(
        status: ReviewsListFetchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    if (state.currentServiceId == null) {
      resetState();
      return;
    }
    await loadFirstPage(
      state.currentServiceId!,
      sortBy: state.currentSortBy,
      sortDir: state.currentSortDir,
    );
  }

  void resetState() {
    state = const ReviewsListState();
  }
}

// 9. 리뷰 목록 Provider 정의
final reviewsListProvider =
    NotifierProvider<ReviewsListNotifier, ReviewsListState>(
  ReviewsListNotifier.new,
);
