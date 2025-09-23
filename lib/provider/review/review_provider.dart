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
import '../../data/dtos/review/reviewCreationRequestDto.dart'; // ReviewCreationRequestDto import 추가

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

// --- Review Creation (리뷰 작성) ---

// 10. 리뷰 생성 상태 Enum
enum ReviewCreationStatus {
  initial,
  loading,
  success,
  error,
}

// 11. 리뷰 생성 상태 클래스
class ReviewCreationState {
  final ReviewCreationStatus status;
  final String? errorMessage;
  final ReviewDto? createdReview; // 생성 성공 시 반환될 수 있는 리뷰 상세 정보

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

// 12. 리뷰 생성 Notifier
class ReviewCreationNotifier extends Notifier<ReviewCreationState> {
  @override
  ReviewCreationState build() {
    return const ReviewCreationState();
  }

  Future<bool> createReview(
      ReviewCreationRequestDto reviewCreationRequestDto) async {
    // ▼▼▼ 로그 추가 ▼▼▼
    print('[ReviewCreationNotifier] createReview 시작');
    print('[ReviewCreationNotifier] 전달받은 reviewCreationRequestDto:');
    print('  serviceId: ${reviewCreationRequestDto.serviceId}');
    print('  bookingId: ${reviewCreationRequestDto.bookingId}');
    print('  rating: ${reviewCreationRequestDto.rating}');
    print('  reviewContent: ${reviewCreationRequestDto.reviewContent}');

    state = state.copyWith(
        status: ReviewCreationStatus.loading,
        clearErrorMessage: true,
        clearCreatedReview: true);

    try {
      final repo = ref.read(reviewRepositoryProvider);

      // ▼▼▼ 로그 추가 ▼▼▼
      print('[ReviewCreationNotifier] reviewRepository.createReview 호출 직전');
      print('  보내는 DTO (JSON): ${reviewCreationRequestDto.toJson()}');

      // ReviewRepository의 createReview는 생성된 ReviewDto를 반환한다고 가정합니다.
      final createdReviewDto =
          await repo.createReview(reviewCreationRequestDto);

      // ▼▼▼ 로그 추가 ▼▼▼
      print('[ReviewCreationNotifier] reviewRepository.createReview 호출 성공');
      print(
          '  서버로부터 받은 createdReviewDto: $createdReviewDto'); // 또는 createdReviewDto.id 등 주요 정보

      state = state.copyWith(
        status: ReviewCreationStatus.success,
        createdReview: createdReviewDto, // API 응답으로 받은 ReviewDto 저장
      );
      // 리뷰 목록이나 통계가 업데이트 되어야 한다면 여기서 해당 Provider를 refresh 할 수 있습니다.
      // 예: ref.invalidate(reviewsListProvider); // 관련 리뷰 목록 새로고침
      // 예: ref.read(reviewsListProvider.notifier).refresh(); // 또는 이렇게 호출
      // 예: ref.invalidate(reviewStatusProvider); // 관련 리뷰 통계 새로고침 (필요시 serviceId 다시 조회)
      print('[ReviewCreationNotifier] createReview 성공 처리 완료');
      return true;
    } catch (e, stackTrace) {
      // ▼▼▼ stackTrace 추가 ▼▼▼
      // ▼▼▼ 로그 추가 ▼▼▼
      print('[ReviewCreationNotifier] createReview 중 심각한 오류 발생: $e');
      print('[ReviewCreationNotifier] StackTrace: $stackTrace');

      state = state.copyWith(
          status: ReviewCreationStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  void resetState() {
    state = const ReviewCreationState();
  }
}

// 13. 리뷰 생성 Provider 정의
final reviewCreationProvider =
    NotifierProvider<ReviewCreationNotifier, ReviewCreationState>(
  ReviewCreationNotifier.new,
);
