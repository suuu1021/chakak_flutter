import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chakak_flutter/data/dtos/review/review_dto.dart';
import 'package:chakak_flutter/data/dtos/paged_response_dto.dart';
import '../../data/models/_repositories/review_repository.dart';
import '../core/dio_provider.dart';

enum PhotographerReviewStatus {
  initial,
  loading,
  success,
  failure,
  loadingMore
}

class PhotographerReviewState {
  final PhotographerReviewStatus status;
  final List<ReviewDto> reviews;
  final int currentPage;
  final int totalPages;
  final bool canLoadMore;
  final String? errorMessage;

  const PhotographerReviewState({
    this.status = PhotographerReviewStatus.initial,
    this.reviews = const <ReviewDto>[],
    this.currentPage = 0,
    this.totalPages = 0,
    this.canLoadMore = true,
    this.errorMessage,
  });

  PhotographerReviewState copyWith({
    PhotographerReviewStatus? status,
    List<ReviewDto>? reviews,
    int? currentPage,
    int? totalPages,
    bool? canLoadMore,
    String? errorMessage,
    bool? clearErrorMessage,
  }) {
    return PhotographerReviewState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      errorMessage:
          clearErrorMessage == true ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PhotographerReviewNotifier
    extends StateNotifier<PhotographerReviewState> {
  final ReviewRepository _reviewRepository;
  final int photographerId;

  PhotographerReviewNotifier(this._reviewRepository, this.photographerId)
      : super(const PhotographerReviewState()) {
    fetchInitialReviews();
  }

  Future<void> fetchInitialReviews({int pageSize = 10}) async {
    if (state.status == PhotographerReviewStatus.loading) return;
    state = state.copyWith(
        status: PhotographerReviewStatus.loading, clearErrorMessage: true);
    try {
      final PagedResponseDto<ReviewDto> pagedResponse =
          await _reviewRepository.getPhotographerReviews(
        photographerId,
        page: 0,
        size: pageSize,
      );
      state = state.copyWith(
        status: PhotographerReviewStatus.success,
        reviews: pagedResponse.content,
        currentPage: pagedResponse.number,
        totalPages: pagedResponse.totalPages,
        canLoadMore: !pagedResponse.last,
      );
    } catch (e) {
      state = state.copyWith(
        status: PhotographerReviewStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMoreReviews({int pageSize = 10}) async {
    if (!state.canLoadMore ||
        state.status == PhotographerReviewStatus.loadingMore) return;

    state = state.copyWith(
        status: PhotographerReviewStatus.loadingMore, clearErrorMessage: true);
    try {
      final nextPage = state.currentPage + 1;
      final PagedResponseDto<ReviewDto> pagedResponse =
          await _reviewRepository.getPhotographerReviews(
        photographerId,
        page: nextPage,
        size: pageSize,
      );
      state = state.copyWith(
        status: PhotographerReviewStatus.success,
        reviews: [...state.reviews, ...pagedResponse.content],
        currentPage: pagedResponse.number,
        totalPages: pagedResponse.totalPages,
        canLoadMore: !pagedResponse.last,
      );
    } catch (e) {
      state = state.copyWith(
        status: PhotographerReviewStatus.success,
        errorMessage: e.toString(),
      );
    }
  }
}

final photographerReviewNotifierProvider = StateNotifierProvider.autoDispose
    .family<PhotographerReviewNotifier, PhotographerReviewState, int>(
        (ref, photographerId) {
  final dio = ref.watch(dioProvider);
  final reviewRepository = ReviewRepository(dio);
  return PhotographerReviewNotifier(reviewRepository, photographerId);
});
