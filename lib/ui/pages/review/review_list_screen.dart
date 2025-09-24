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
          _buildReviewStatusSection(reviewStatusState, isStatusForThisService),
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
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("통계 로딩 실패: ${reviewStatusState.errorMessage}",
            style: const TextStyle(color: Colors.red)),
      );
    }
    return const SizedBox(height: 50);
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
        // ReviewDto를 Review 모델로 변환 (toModel 사용)
        final Review reviewModel = reviewDto.toModel();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ReviewCardWidget(
            review: reviewModel,
            mode: "user",
            onTap: () {
              // 서비스 상세 페이지로 이동
              // PhotoService 객체 생성 시 필요한 정보들은 현재 컨텍스트에서 가져올 수 있는 값으로 채워야 합니다.
              // 예를 들어, title, photographerId 등은 reviewDto 또는 다른 Provider에서 가져올 수 있습니다.
              // 여기서는 임시 값으로 설정하며, 실제 프로젝트에서는 정확한 데이터로 채워야 합니다.
              final dummyService = PhotoService(
                id: widget.serviceId, // 현재 화면의 serviceId 사용
                photographerId: 1, // TODO: 실제 사진작가 ID로 교체 필요
                photographerUserId: int.tryParse(reviewDto.reviewerId) ?? 0, // DTO의 reviewerId를 사용 (userId로 간주)
                title: "서비스 상세", // TODO: 실제 서비스 제목으로 교체 필요
                imageUrl: reviewModel.thumbnailUrl ?? "https://via.placeholder.com/150",
                categories: [], // TODO: 실제 카테고리 정보로 교체 필요
                price: 0, // TODO: 실제 가격 정보로 교체 필요
                rating: reviewModel.rating,
                reviewCount: reviewsListState.reviews.length, // TODO: 더 정확한 리뷰 카운트 로직 필요 (전체 카운트 등)
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
