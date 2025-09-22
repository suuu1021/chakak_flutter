import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/community/post.dart';
import '../../../data/models/repositories/community_repository.dart';
import 'community_repository_provider.dart';

/*
 * 게시글 상태를 관리하는 State 클래스
 */
class PostState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  const PostState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  PostState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/*
 * 게시글 상태를 관리하는 Notifier
 * 게시글 CRUD와 좋아요 기능을 담당합니다.
 */
class PostNotifier extends Notifier<PostState> {
  late CommunityRepository _repository;

  @override
  PostState build() {
    _repository = ref.watch(communityRepositoryProvider);
    return const PostState();
  }

  /*
   * 게시글 목록을 로드합니다.
   */
  Future<void> loadPosts() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final posts = await _repository.fetchAllPosts();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /*
   * 새 게시글을 작성합니다.
   */
  Future<void> createPost(Post post) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final newPost = await _repository.createPost(post);
      final updatedPosts = [newPost, ...state.posts];
      state = state.copyWith(posts: updatedPosts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /*
   * 게시글을 수정합니다.
   */
  Future<void> updatePost(String postId, Post post) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final updatedPost = await _repository.updatePost(postId, post);
      final updatedPosts = state.posts.map((p) {
        return p.id == postId ? updatedPost : p;
      }).toList();
      state = state.copyWith(posts: updatedPosts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /*
   * 게시글을 삭제합니다.
   */
  Future<void> deletePost(String postId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.deletePost(postId);
      final updatedPosts = state.posts.where((p) => p.id != postId).toList();
      state = state.copyWith(posts: updatedPosts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /*
   * 특정 게시글에 좋아요를 토글합니다.
   */
  Future<void> togglePostLike(String postId) async {
    final currentPost = state.posts.firstWhere((post) => post.id == postId);
    final isCurrentlyLiked = currentPost.isLiked;

    // 1. 낙관적 UI 업데이트
    final updatedList = state.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !isCurrentlyLiked,
          likeCount: isCurrentlyLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedList);

    // 2. 서버 요청
    try {
      if (isCurrentlyLiked) {
        await _repository.unlikePost(postId);
      } else {
        await _repository.likePost(postId);
      }
    } catch (e) {
      // 3. 실패 시 상태 복구
      final revertedList = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: isCurrentlyLiked,
            likeCount:
                isCurrentlyLiked ? post.likeCount + 1 : post.likeCount - 1,
          );
        }
        return post;
      }).toList();
      state = state.copyWith(posts: revertedList, error: e.toString());
    }
  }
}

// ===================== Provider 정의 =====================

// 게시글 목록 NotifierProvider
final postProvider = NotifierProvider<PostNotifier, PostState>(
  () => PostNotifier(),
);

// 특정 게시글 상세 FutureProvider
final postDetailProvider = FutureProvider.family<Post, String>((ref, id) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.fetchPostById(id);
});
