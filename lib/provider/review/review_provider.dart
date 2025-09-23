import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core DioProvider
import 'package:chakak_flutter/provider/core/dio_provider.dart';

// Repositories
import 'package:chakak_flutter/data/models/repositories/review_repository.dart';

// DTOs
import 'package:chakak_flutter/data/dtos/review/review_status_dto.dart';
import 'package:chakak_flutter/data/dtos/review/review_dto.dart';
import 'package:chakak_flutter/data/dtos/paged_response_dto.dart';
import 'package:chakak_flutter/data/dtos/review/reviewCreationRequestDto.dart';

/// --------------------
/// ReviewRepository Provider
/// --------------------
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewRepository(dio);
});

/// --------------------
/// Review Status (특정 서비스의 리뷰 통계)
/// --------------------
enum ReviewServiceFetchStatus { initial, loading, success, error }

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

class ReviewServiceStatusNotifier extends Notifier<ReviewServiceStatusState> {
  @override
  ReviewServiceStatusState build() => const ReviewServiceStatusState();

  Future<void> fetchStatus(int serviceId) async {
    if (state.status == ReviewServiceFetchStatus.loading &&
        state.currentServiceId == serviceId) return;

    final repo = ref.read(reviewRepositoryProvider);
    state = state.copyWith(
      status: ReviewServiceFetchStatus.loading,
      currentServiceId: serviceId,
      clearData: true,
      clearErrorMessage: true,
    );

    try {
      final statusData = await repo.getReviewStatus(serviceId);
      state = state.copyWith(
        status: ReviewServiceFetchStatus.success,
        data: statusData,
      );
    } catch (e) {
      state = state.copyWith(
        status: ReviewServiceFetchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void resetState() => state = const ReviewServiceStatusState();
}

final reviewStatusProvider = NotifierProvider<ReviewServiceStatusNotifier,
    ReviewServiceStatusState>(ReviewServiceStatusNotifier.new);

/// --------------------
/// Reviews List (특정 서비스 리뷰 목록, 페이지네이션 포함)
/// --------------------
enum ReviewsListFetchStatus {
  initial,
  loadingFirstPage,
  loadingMore,
  success,
  error,
  allLoaded,
}

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

class ReviewsListNotifier extends Notifier<ReviewsListState> {
  final int _pageSize = 10;

  @override
  ReviewsListState build() => const ReviewsListState();

  Future<void> loadFirstPage(int serviceId,
      {String? sortBy, String? sortDir}) async {
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
        sortBy: sortBy,
        sortDir: sortDir,
      );

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
        !state.canLoadMore) return;

    state = state.copyWith(
      status: ReviewsListFetchStatus.loadingMore,
      clearErrorMessage: true,
    );

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
      state = state.copyWith(
        status: ReviewsListFetchStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void resetState() => state = const ReviewsListState();
}

final reviewsListProvider =
NotifierProvider<ReviewsListNotifier, ReviewsListState>(
    ReviewsListNotifier.new);

/// --------------------
/// Review Creation (리뷰 작성)
/// --------------------
enum ReviewCreationStatus { initial, loading, success, error }

class ReviewCreationState {
  final ReviewCreationStatus status;
  final String? errorMessage;
  final ReviewDto? createdReview;

  const ReviewCreationState({
    this.status = ReviewCreationStatus.initial,
    this.errorMessage,
    this.createdReview,
  });

  ReviewCreationState copyWith({
    ReviewCreationStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    ReviewDto? createdReview,
    bool clearCreatedReview = false,
  }) {
    return ReviewCreationState(
      status: status ?? this.status,
      errorMessage:
      clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      createdReview:
      clearCreatedReview ? null : createdReview ?? this.createdReview,
    );
  }
}

class ReviewCreationNotifier extends Notifier<ReviewCreationState> {
  @override
  ReviewCreationState build() => const ReviewCreationState();

  Future<bool> createReview(
      ReviewCreationRequestDto reviewCreationRequestDto) async {
    state = state.copyWith(
      status: ReviewCreationStatus.loading,
      clearErrorMessage: true,
      clearCreatedReview: true,
    );

    try {
      final repo = ref.read(reviewRepositoryProvider);
      final createdReviewDto =
      await repo.createReview(reviewCreationRequestDto);

      state = state.copyWith(
        status: ReviewCreationStatus.success,
        createdReview: createdReviewDto,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ReviewCreationStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void resetState() => state = const ReviewCreationState();
}

final reviewCreationProvider =
NotifierProvider<ReviewCreationNotifier, ReviewCreationState>(
    ReviewCreationNotifier.new);

/// --------------------
/// Recent Reviews (최근 리뷰 5개)
/// --------------------
final recentReviewsProvider =
FutureProvider.family<List<ReviewDto>, int>((ref, serviceId) async {
  final repo = ref.read(reviewRepositoryProvider);
  final reviews = await repo.getRecentReviews(serviceId);
  return reviews;
});
