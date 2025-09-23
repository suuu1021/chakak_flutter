import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dtos/review/review_dto.dart';
import '../../../data/models/review.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../provider/review/review_provider.dart';
import '../photo_service/photo_service_detail_page.dart';
import 'widgets/review_card_widget.dart';

class ReviewListScreen extends ConsumerStatefulWidget {
  final int serviceId;

  const ReviewListScreen({
    super.key,
    required this.serviceId,
  });

  @override
  ConsumerState<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends ConsumerState<ReviewListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reviewsListProvider.notifier).loadFirstPage(widget.serviceId,
          sortBy: "createdAt", sortDir: "desc");
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(reviewsListProvider.notifier).loadMoreReviews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewsListProvider);
    final reviewStatusState = ref.watch(reviewStatusProvider);

    // 현재 화면의 serviceId와 Provider의 serviceId가 일치하는지 확인
    final bool isDataForThisService =
        reviewState.currentServiceId == widget.serviceId;
    final bool isStatusForThisService =
        reviewStatusState.currentServiceId == widget.serviceId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("리뷰 전체보기"),
      ),
      body: Column(
        children: [
          // 리뷰 통계 섹션
          _buildReviewStatusSection(reviewStatusState, isStatusForThisService),
          // 리뷰 리스트 섹션
          Expanded(
            child: _buildReviewListSection(reviewState, isDataForThisService),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStatusSection(
      ReviewServiceStatusState reviewStatusState, bool isDataForThisService) {
    if (reviewStatusState.status == ReviewServiceFetchStatus.loading &&
        !isDataForThisService) {
      return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()));
    }
    if (reviewStatusState.status == ReviewServiceFetchStatus.success &&
        reviewStatusState.data != null &&
        isDataForThisService) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
                "평균 평점: ⭐ ${reviewStatusState.data!.averageRating.toStringAsFixed(1)}"),
            Text("총 리뷰 수: ${reviewStatusState.data!.totalReviews}개"),
          ],
        ),
      );
    }
    if (reviewStatusState.status == ReviewServiceFetchStatus.error &&
        isDataForThisService) {
      // 현재 서비스에 대한 에러일 때만 표시
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("통계 로딩 실패: ${reviewStatusState.errorMessage}",
            style: const TextStyle(color: Colors.red)),
      );
    }
    // 기본적으로 빈 위젯 반환 (데이터가 없거나 다른 서비스 ID의 초기 상태 등)
    return const SizedBox(height: 50); // 로딩 표시 공간 확보 또는 빈 공간
  }

  Widget _buildReviewListSection(
      ReviewsListState reviewsListState, bool isDataForThisService) {
    if (reviewsListState.status == ReviewsListFetchStatus.loadingFirstPage &&
        reviewsListState.reviews.isEmpty &&
        !isDataForThisService) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviewsListState.status == ReviewsListFetchStatus.error &&
        reviewsListState.reviews.isEmpty &&
        isDataForThisService) {
      // 현재 서비스에 대한 에러일 때
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("리뷰를 불러오는데 실패했습니다: ${reviewsListState.errorMessage}"),
            ElevatedButton(
              onPressed: () => ref
                  .read(reviewsListProvider.notifier)
                  .loadFirstPage(widget.serviceId),
              child: const Text("재시도"),
            )
          ],
        ),
      );
    }

    if (reviewsListState.reviews.isEmpty &&
        (reviewsListState.status == ReviewsListFetchStatus.success ||
            reviewsListState.status == ReviewsListFetchStatus.allLoaded) &&
        isDataForThisService) {
      return const Center(child: Text("작성된 리뷰가 없습니다."));
    }

    // 데이터가 있지만 현재 화면의 serviceId와 Provider의 serviceId가 다른 경우 (화면 전환 중) 로딩 표시
    if (!isDataForThisService &&
        reviewsListState.status != ReviewsListFetchStatus.initial &&
        reviewsListState.status != ReviewsListFetchStatus.error) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: reviewsListState.reviews.length +
          ((reviewsListState.status == ReviewsListFetchStatus.loadingMore ||
                  (reviewsListState.status ==
                          ReviewsListFetchStatus.allLoaded &&
                      reviewsListState.reviews.isNotEmpty))
              ? 1
              : 0),
      itemBuilder: (context, index) {
        if (index == reviewsListState.reviews.length) {
          if (reviewsListState.status == ReviewsListFetchStatus.loadingMore) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator()));
          } else if (reviewsListState.status ==
                  ReviewsListFetchStatus.allLoaded &&
              reviewsListState.reviews.isNotEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("모든 리뷰를 불러왔습니다.")));
          }
          return const SizedBox.shrink();
        }

        final ReviewDto reviewDto = reviewsListState.reviews[index];
        final Review reviewModel = Review(
          id: reviewDto.id,
          reviewerId: reviewDto.reviewerId,
          serviceId: reviewDto.serviceId,
          bookingId: reviewDto.bookingId,
          rating: reviewDto.rating,
          reviewContent: reviewDto.reviewContent,
          createdAt: reviewDto.createdAt,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ReviewCardWidget(
            review: reviewModel,
            mode: "user",
            onTap: () {
              // 서비스 상세 페이지로 이동
              final dummyService = PhotoService(
                id: int.tryParse(reviewModel.serviceId ?? '') ?? 0,
                photographerId: 1,
                photographerUserId: 0,
                title: "서비스 상세",
                imageUrl: "https://via.placeholder.com/150",
                categories: [],
                price: 0,
                rating: 0,
                reviewCount: 0,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        PhotoServiceDetailPage(service: dummyService)),
              );
            },
          ),
        );
      },
    );
  }
}
