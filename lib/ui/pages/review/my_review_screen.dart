import 'package:chakak_flutter/data/dtos/paged_response_dto.dart';
import 'package:chakak_flutter/data/dtos/review/review_dto.dart';
import 'package:chakak_flutter/data/models/repositories/review_repository.dart';
import 'package:flutter/material.dart';
import 'package:chakak_flutter/ui/pages/review/widgets/review_card_widget.dart';
import '../../../data/models/review.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/core/dio_provider.dart';
import '../../../provider/global/photoService/photo_service_provider.dart';
// import '../profile/photographer/photographer_profile_page.dart'; // 이전 import 삭제
import '../photo_service/photo_service_detail_page.dart'; // <<<<<<< PhotoServiceDetailPage import 추가
import 'package:chakak_flutter/data/models/photo_service/photo_service.dart';


// ReviewRepository를 제공하는 Provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewRepository(dio);
});

class MyReviewScreen extends ConsumerStatefulWidget {
  const MyReviewScreen({super.key});

  @override
  ConsumerState<MyReviewScreen> createState() => _MyReviewScreenState();
}

class _MyReviewScreenState extends ConsumerState<MyReviewScreen> {
  late Future<PagedResponseDto<ReviewDto>> _myReviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadMyReviews();
  }

  void _loadMyReviews() {
    final reviewRepository = ref.read(reviewRepositoryProvider);
    _myReviewsFuture = reviewRepository.getMyReviews();
  }

  void _retryLoadMyReviews() {
    setState(() {
      _loadMyReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내가 작성한 리뷰"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<PagedResponseDto<ReviewDto>>(
        future: _myReviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("리뷰를 불러오는데 실패했습니다: ${snapshot.error}", textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryLoadMyReviews,
                    child: const Text("다시 시도"),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData) {
            final reviews = snapshot.data!.content;
            if (reviews.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rate_review_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "작성한 리뷰가 없습니다.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final reviewDto = reviews[index];
                final reviewModel = reviewDto.toModel();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ReviewCardWidget(
                    review: reviewModel,
                    mode: "user",
                    onTap: () async {
                      if (reviewModel.serviceId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("서비스 ID가 없어 상세 페이지로 이동할 수 없습니다.")),
                        );
                        return;
                      }
                      try {
                        final intServiceId = int.parse(reviewModel.serviceId!);
                        final PhotoService? photoService = await ref.read(photoServiceProvider.notifier).loadServiceDetail(intServiceId);

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
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
