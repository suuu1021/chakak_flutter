import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/repositories/community_repository.dart';
import '../../core/dio_provider.dart';

/*
 * CommunityRepository 인스턴스를 제공하는 Provider
 * 게시글과 댓글 Provider에서 공통으로 사용됩니다.
 */
final communityRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return CommunityRepository(dio);
});
