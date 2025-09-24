import 'package:chakak_flutter/data/models/repositories/review_repository.dart';
import 'package:chakak_flutter/provider/core/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ReviewRepository 인스턴스를 제공하는 Provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  // dioProvider를 watch하여 Dio 인스턴스를 가져옵니다.
  final dio = ref.watch(dioProvider);
  // Dio 인스턴스를 사용하여 ReviewRepository를 생성하고 반환합니다.
  return ReviewRepository(dio);
});
