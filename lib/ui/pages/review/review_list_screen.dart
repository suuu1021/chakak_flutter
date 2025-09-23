import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dtos/review/review_dto.dart';
import '../../../provider/review/review_provider.dart';
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
      ref
          .read(reviewsListProvider.notifier)
          .loadFirstPage(widget.serviceId, sortBy: "createdAt", sortDir: "desc");
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("리뷰 전체보기"),
      ),
      body: reviewState.status == ReviewsListFetchStatus.loadingFirstPage
          ? const Center(child: CircularProgressIndicator())
          : reviewState.status == ReviewsListFetchStatus.error
          ? Center(child: Text("에러: ${reviewState.errorMessage}"))
          : ListView.builder(
        controller: _scrollController,
        itemCount: reviewState.reviews.length +
            (reviewState.canLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < reviewState.reviews.length) {
            final ReviewDto review = reviewState.reviews[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: ReviewCardWidget(
                review: review.toModel(),
                mode: "user",
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
