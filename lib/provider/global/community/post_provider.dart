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

  /*
   * 특정 게시글 찾기 헬퍼 메서드
   */
  Post? findPostById(String postId) {
    try {
      return posts.firstWhere((p) => p.id == postId);
    } catch (e) {
      return null;
    }
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
      print('받아온 posts 개수: ${posts.length}');
      if (posts.isNotEmpty) {
        print('첫 번째 게시글 replyCount: ${posts.first.replyCount}');
      }
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
   * 특정 게시글이 상태에 있는지 확인하고, 없으면 서버에서 가져옵니다.
   * 단일 데이터 소스의 핵심 메서드
   */
  Future<Post?> findOrFetchPost(String postId) async {
    // 이미 게시글이 상태에 있는지 확인
    final existingPost = state.findPostById(postId);
    if (existingPost != null) {
      return existingPost;
    }

    try {
      // 개별 게시글 로딩은 전체 로딩 상태에 영향주지 않음
      final fetchedPost = await _repository.fetchPostById(postId);

      // 기존 목록에 게시글 추가
      final updatedPosts = [...state.posts, fetchedPost];
      state = state.copyWith(posts: updatedPosts);

      return fetchedPost;
    } catch (e) {
      state = state.copyWith(error: "게시글을 가져오는 데 실패했습니다: $e");
      return null;
    }
  }

  Future<Post?> getDetailPost(String postId) async {
    try {
      final detailPost =
          await _repository.fetchPostDetailById(postId); // 로그인 필요 전용 ✅
      final updatedPosts = [
        for (final p in state.posts)
          if (p.id == postId) detailPost else p
      ];
      if (!state.posts.any((p) => p.id == postId)) {
        updatedPosts.add(detailPost);
      }

      state = state.copyWith(posts: updatedPosts);
      return detailPost;
    } catch (e) {
      state = state.copyWith(error: "상세 불러오기 실패: $e");
      return null;
    }
  }

  /*
   * 특정 게시글에 좋아요를 토글합니다.
   */
  Future<void> togglePostLike(String postId) async {
    // 게시글이 상태에 있는지 확인하고 없으면 가져옵니다.
    final post = await findOrFetchPost(postId);
    if (post == null) return;

    // 낙관적 UI 업데이트
    final isLiked = !post.isLiked;
    final likeCount = isLiked ? post.likeCount + 1 : post.likeCount - 1;
    _updatePostState(post, isLiked, likeCount);

    try {
      // 서버에 좋아요 상태를 동기화
      await _repository.togglePostLike(postId);
    } catch (e) {
      // 실패 시 상태를 원래대로 복구
      _updatePostState(post, !isLiked, post.likeCount);
      state = state.copyWith(error: "좋아요 동기화에 실패했습니다: $e");
    }
  }

  /*
   * 게시글 상태 업데이트 헬퍼 메서드
   */
  void _updatePostState(Post post, bool isLiked, int likeCount) {
    final updatedPost = post.copyWith(isLiked: isLiked, likeCount: likeCount);
    final newPosts =
        state.posts.map((p) => p.id == post.id ? updatedPost : p).toList();
    state = state.copyWith(posts: newPosts);
  }
}

// ===================== Provider 정의 =====================

// 게시글 목록 NotifierProvider (단일 데이터 소스)
final postProvider = NotifierProvider<PostNotifier, PostState>(
  () => PostNotifier(),
);
