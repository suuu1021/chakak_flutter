import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chakak_flutter/provider/review/photographer_review_notifier.dart';
import 'package:chakak_flutter/data/dtos/review/review_dto.dart'; // ReviewDto 사용을 위해
import '../../../data/models/review.dart'; // Review 모델 (ReviewCardWidget에서 사용)
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'widgets/review_card_widget.dart';
// 추가된 import 문들
import '../../../provider/global/photoService/photo_service_provider.dart';
import '../photo_service/photo_service_detail_page.dart';
import '../../../data/models/photo_service/photo_service.dart';

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
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        mounted) {
      final notifier = ref.read(
          photographerReviewNotifierProvider(widget.photographerId).notifier);
      final state =
          ref.read(photographerReviewNotifierProvider(widget.photographerId));
      if (state.canLoadMore &&
          state.status != PhotographerReviewStatus.loadingMore &&
          state.status != PhotographerReviewStatus.loading) {
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
    if (reviewState.status == PhotographerReviewStatus.loading &&
        reviewState.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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
                  if (mounted) {
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

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: reviewState.reviews.length +
          (reviewState.status == PhotographerReviewStatus.loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == reviewState.reviews.length &&
            reviewState.status == PhotographerReviewStatus.loadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (index >= reviewState.reviews.length) {
            return const SizedBox.shrink(); 
        }

        final reviewDto = reviewState.reviews[index];
        final reviewModel = reviewDto.toModel();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ReviewCardWidget(
            review: reviewModel,
            mode: "photographer",
            onTap: () async {
              // MyReviewScreen의 로직을 참고하여 onTap 로직 구현
              if (reviewModel.serviceId == null || reviewModel.serviceId!.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("서비스 ID가 없어 상세 페이지로 이동할 수 없습니다.")),
                  );
                }
                return;
              }
              try {
                // reviewModel.serviceId가 String 타입이라고 가정.
                final int? intServiceId = int.tryParse(reviewModel.serviceId!);
                if (intServiceId == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("유효하지 않은 서비스 ID 형식입니다.")),
                    );
                  }
                  return;
                }

                // 로딩 인디케이터를 보여주는 로직 (선택 사항)
                // 예: showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()));

                final PhotoService? photoService = await ref
                    .read(photoServiceProvider.notifier)
                    .loadServiceDetail(intServiceId);
                
                // if (mounted) Navigator.of(context).pop(); // 로딩 인디케이터 닫기

                if (photoService != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoServiceDetailPage(service: photoService),
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("해당 서비스 정보를 찾을 수 없습니다.")),
                  );
                }
              } catch (e) {
                // if (mounted) Navigator.of(context).pop(); // 로딩 인디케이터 닫기 (오류 발생 시)
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("상세 페이지 이동 중 오류 발생: $e")),
                  );
                }
              }
            },
          ),
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
