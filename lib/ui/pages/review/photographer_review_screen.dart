import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chakak_flutter/provider/review/photographer_review_notifier.dart';
import 'package:chakak_flutter/data/dtos/review/review_dto.dart'; // ReviewDto 사용을 위해
import '../../../data/models/review.dart'; // Review 모델 (ReviewCardWidget에서 사용)
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'widgets/review_card_widget.dart';

class PhotographerReviewScreen extends ConsumerStatefulWidget {
  final int photographerId;

  const PhotographerReviewScreen({super.key, required this.photographerId});

  @override
  ConsumerState<PhotographerReviewScreen> createState() =>
      _PhotographerReviewScreenState();
}

class _PhotographerReviewScreenState
    extends ConsumerState<PhotographerReviewScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 초기 데이터 로드는 Notifier가 생성될 때 자동으로 호출됩니다.
    // 필요하다면 여기서 명시적으로 호출할 수도 있습니다.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) { // mounted 확인 추가
    //     ref.read(photographerReviewNotifierProvider(widget.photographerId).notifier).fetchInitialReviews();
    //   }
    // });
  }

  void _onScroll() {
    // 스크롤 위치가 거의 끝에 도달했고, 추가 로드가 가능하며, 현재 로딩 중이 아닐 때
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 && // 200px 정도 여유
        mounted) { // mounted 확인 추가
      final notifier = ref.read(
          photographerReviewNotifierProvider(widget.photographerId).notifier);
      final state =
          ref.read(photographerReviewNotifierProvider(widget.photographerId));
      if (state.canLoadMore &&
          state.status != PhotographerReviewStatus.loadingMore &&
          state.status != PhotographerReviewStatus.loading) { // 초기 로딩 중에도 호출 방지
        notifier.loadMoreReviews();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewState =
        ref.watch(photographerReviewNotifierProvider(widget.photographerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("받은 리뷰 관리"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildBody(context, reviewState),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildBody(BuildContext context, PhotographerReviewState reviewState) {
    // 초기 로딩 중 (리뷰가 하나도 없을 때)
    if (reviewState.status == PhotographerReviewStatus.loading &&
        reviewState.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 데이터 로드 실패 (리뷰가 하나도 없을 때)
    if (reviewState.status == PhotographerReviewStatus.failure &&
        reviewState.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              Text(
                "리뷰를 불러오는데 실패했습니다.\n${reviewState.errorMessage ?? '알 수 없는 오류가 발생했습니다.'}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (mounted) { // mounted 확인 추가
                     ref.read(photographerReviewNotifierProvider(widget.photographerId)
                            .notifier)
                        .fetchInitialReviews();
                  }
                },
                child: const Text("다시 시도"),
              ),
            ],
          ),
        ),
      );
    }

    // 리뷰가 없는 경우 (성공적으로 로드했으나 비어있음)
    if (reviewState.status == PhotographerReviewStatus.success &&
        reviewState.reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "아직 받은 리뷰가 없습니다.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 리뷰 목록 표시
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      // 리뷰 아이템 수 + 추가 로딩 중일 경우 인디케이터를 위한 1개
      itemCount: reviewState.reviews.length +
          (reviewState.status == PhotographerReviewStatus.loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // 추가 로딩 인디케이터 표시
        if (index == reviewState.reviews.length &&
            reviewState.status == PhotographerReviewStatus.loadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // 범위를 벗어난 인덱스 접근 방지 (매우 드문 경우에 대한 안전 장치)
        if (index >= reviewState.reviews.length) {
            return const SizedBox.shrink(); 
        }

        final reviewDto = reviewState.reviews[index];
        final reviewModel = reviewDto.toModel(); // ReviewDto를 Review 모델로 변환
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ReviewCardWidget(review: reviewModel, mode: "photographer"), // 수정된 부분
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
