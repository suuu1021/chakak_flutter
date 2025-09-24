import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dtos/paged_response_dto.dart';
import '../../../data/dtos/review/review_dto.dart';
import '../../../data/models/repositories/review_repository.dart';
import '../../core/dio_provider.dart';

/// --------------------
/// Repository Provider
/// --------------------
final photographerReviewsRepositoryProvider =
Provider<ReviewRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewRepository(dio);
});

/// --------------------
/// Photographer Reviews Provider
/// --------------------
final photographerReviewsProvider = FutureProvider.family<
    PagedResponseDto<ReviewDto>, int>((ref, photographerId) async {
  final repo = ref.read(photographerReviewsRepositoryProvider);
  return repo.getPhotographerReviews(photographerId);
});
