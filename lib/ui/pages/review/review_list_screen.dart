import 'package:chakak_flutter/data/dtos/review/review_dto.dart';
import 'package:chakak_flutter/provider/review/review_provider.dart';
import 'package:chakak_flutter/ui/pages/review/widgets/review_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/photo_service/photo_service.dart'; // onTap 예시용
import '../../../data/models/review.dart';
import '../../../ui/pages/photo_service/photo_service_detail_page.dart'; // onTap 예시용

class ReviewListScreen extends ConsumerStatefulWidget {
  final int serviceId;

  const ReviewListScreen({super.key, required this.serviceId});

  @override
  ConsumerState<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends ConsumerState<ReviewListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // initState에서 ref.read를 사용하여 Provider의 메소드를 호출합니다.
    // 위젯 트리에 Provider가 연결된 후 안전하게 호출하기 위해 Future.microtask 사용.
    Future.microtask(() {
      final reviewStatusNotifier = ref.read(reviewStatusProvider.notifier);
      final reviewsListNotifier = ref.read(reviewsListProvider.notifier);

      // 데이터가 없거나 다른 서비스 ID의 데이터일 경우에만 새로 로드
      if (ref.read(reviewStatusProvider).currentServiceId != widget.serviceId) {
        reviewStatusNotifier.fetchStatus(widget.serviceId);
      }
      if (ref.read(reviewsListProvider).currentServiceId != widget.serviceId ||
          ref.read(reviewsListProvider).reviews.isEmpty) {
        reviewsListNotifier.loadFirstPage(widget.serviceId);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 끝에서 200px 전에 로드 시작
      final notifier = ref.read(reviewsListProvider.notifier);
      final state = ref.read(reviewsListProvider);
      if (state.canLoadMore &&
          state.status != ReviewsListFetchStatus.loadingMore) {
        notifier.loadMoreReviews();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewStatusState = ref.watch(reviewStatusProvider);
    final reviewsListState = ref.watch(reviewsListProvider);

    final bool isDataForThisService =
        reviewsListState.currentServiceId == widget.serviceId &&
            reviewStatusState.currentServiceId == widget.serviceId;

    return Scaffold(
      appBar: AppBar(title: Text("리뷰 (서비스 ID: ${widget.serviceId})")),
      body: RefreshIndicator(
        onRefresh: () async {
          // Provider의 상태를 초기화하거나, Notifier에 refresh 메소드가 있다면 그것을 호출
          // 여기서는 첫 페이지를 다시 로드하고 통계도 새로고침합니다.
          ref
              .read(reviewsListProvider.notifier)
              .loadFirstPage(widget.serviceId);
          ref.read(reviewStatusProvider.notifier).fetchStatus(widget.serviceId);
        },
        child: Column(
          children: [
            _buildReviewStatusSection(reviewStatusState, isDataForThisService),
            const Divider(),
            Expanded(
                child: _buildReviewListSection(
                    reviewsListState, isDataForThisService)),
          ],
        ),
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

        return ReviewCardWidget(
          review: reviewModel,
          mode: "user", // TODO: 적절한 모드 설정
          onTap: () {
            // TODO: onTap 로직 정의
            final dummyService = PhotoService(
              id: int.tryParse(reviewModel.serviceId ?? '') ?? 0,
              photographerId: 1,
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
        );
      },
    );
  }
}
