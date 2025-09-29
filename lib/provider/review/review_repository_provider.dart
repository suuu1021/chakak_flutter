import 'package:chakak_flutter/provider/core/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/_repositories/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewRepository(dio);
});
