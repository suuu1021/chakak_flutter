import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/community/reply.dart';
import '../../../data/models/repositories/community_repository.dart';
import 'community_repository_provider.dart';
import 'post_provider.dart';

/*
 * 댓글 상태를 관리하는 State 클래스
 */
class ReplyState {
  final List<Reply> replies;
  final bool isLoading;
  final String? error;

  const ReplyState({
    this.replies = const [],
    this.isLoading = false,
    this.error,
  });

  ReplyState copyWith({
    List<Reply>? replies,
    bool? isLoading,
    String? error,
  }) {
    return ReplyState(
      replies: replies ?? this.replies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/*
 * 댓글 상태를 관리하는 Notifier
 * 댓글 CRUD 기능을 담당합니다.
 */
class ReplyNotifier extends Notifier<ReplyState> {
  late CommunityRepository _repository;

  @override
  ReplyState build() {
    _repository = ref.watch(communityRepositoryProvider);
    return const ReplyState();
  }

  /*
   * 특정 게시글의 댓글을 로드합니다.
   */
  Future<void> loadReplies(String postId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final replies = await _repository.fetchRepliesForPost(postId);
      state = state.copyWith(replies: replies, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /*
   * 새 댓글을 작성합니다.
   */
  Future<void> createReply(String postId, Reply reply) async {
    try {
      final newReply = await _repository.createReply(postId, reply);
      final updatedReplies = [...state.replies, newReply];
      state = state.copyWith(replies: updatedReplies);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /*
   * 댓글을 수정합니다.
   */
  Future<void> updateReply(String postId, String replyId, Reply reply) async {
    try {
      final updatedReply =
          await _repository.updateReply(postId, replyId, reply);
      final updatedReplies = state.replies.map((r) {
        return r.id == replyId ? updatedReply : r;
      }).toList();
      state = state.copyWith(replies: updatedReplies);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /*
   * 댓글을 삭제합니다.
   */
  Future<void> deleteReply(String postId, String replyId) async {
    try {
      await _repository.deleteReply(postId, replyId);
      final updatedReplies =
          state.replies.where((r) => r.id != replyId).toList();
      state = state.copyWith(replies: updatedReplies);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// ===================== Provider 정의 =====================

// 댓글 목록 NotifierProvider
final replyProvider = NotifierProvider<ReplyNotifier, ReplyState>(
  () => ReplyNotifier(),
);
