import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/_repositories/community_repository.dart';
import '../core/dio_provider.dart';

// CommunityRepository 인스턴스를 제공하는 Provider
final communityRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return CommunityRepository(dio);
});
