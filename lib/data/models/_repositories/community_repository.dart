import 'package:dio/dio.dart';

import '../../../_core/constants/api_config.dart';
import '../../dtos/community/post_list_dto.dart';
import '../../dtos/community/post_detail_dto.dart';
import '../../dtos/community/post_create_request_dto.dart';
import '../../dtos/community/post_update_request_dto.dart';
import '../../dtos/community/reply_dto.dart';
import '../community/post.dart';
import '../community/reply.dart';

class CommunityRepository {
  final Dio _dio;
  final String _baseUrl = ApiConfig.baseUrl;

  CommunityRepository(this._dio);

  Future<List<Post>> fetchAllPosts() async {
    try {
      print('=== fetchAllPosts 시작 ===');
      final response = await _dio.get('$_baseUrl/api/post/list');
      print('요청 URL: $_baseUrl/api/post/list');
      print('서버 응답 전체: ${response.data}');

      if (response.data['body'] != null &&
          response.data['body']['content'] != null) {
        final List<dynamic> jsonList = response.data['body']['content'];
        final posts = jsonList.map((json) {
          final post = PostListDto.fromJson(json).toModel();
          print('변환된 Post - id: ${post.id}, replyCount: ${post.replyCount}');
          return post;
        }).toList();

        print('=== 총 ${posts.length}개 게시글 로드 완료 ===');
        return posts;
      } else {
        return [];
      }
    } catch (e) {
      print('fetchAllPosts 에러: $e');
      rethrow;
    }
  }

  /*
   * 특정 게시글 단일 조회 (리스트 등에서 사용)
   * API: GET /api/post/{postId}
   */
  Future<Post> fetchPostById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/api/post/$id');
      print('fetchPostById 응답 데이터: ${response.data}');

      final Map<String, dynamic> responseData = response.data['body'];
      final post = PostDetailDto.fromJson(responseData).toModel();
      return post;
    } on DioException catch (e) {
      throw _handleDioError(e, '게시글 단일 조회');
    }
  }

  /*
   * 특정 게시글 상세 조회 (로그인 필요 전용)
   * API: GET /api/post/{postId}
   */
  Future<Post> fetchPostDetailById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/api/post/$id');
      print('fetchPostDetailById 응답 데이터: ${response.data}');

      final Map<String, dynamic> responseData = response.data['body'];
      final post = PostDetailDto.fromJson(responseData).toModel();
      return post;
    } on DioException catch (e) {
      throw _handleDioError(e, '게시글 상세 조회(로그인 필요)');
    }
  }

  /*
   * 새 게시글을 생성합니다.
   * API: POST /api/post
   */
  Future<Post> createPost(Post post) async {
    try {
      // Post 모델을 생성 요청 DTO로 변환
      final requestDto = PostCreateRequestDto(
        title: post.title,
        content: post.content,
        imageData: post.imageUrl,
      );
      final response = await _dio.post(
        '$_baseUrl/api/post',
        data: requestDto.toJson(),
      );
      final Map<String, dynamic> responseData = response.data['body'];
      return PostDetailDto.fromJson(responseData).toModel();
    } on DioException catch (e) {
      throw _handleDioError(e, '게시글 작성');
    }
  }

  /*
   * 게시글을 수정합니다.
   * API: PUT /api/post/{postId}
   */
  Future<Post> updatePost(String postId, Post post) async {
    try {
      // Post 모델을 수정 요청 DTO로 변환
      final requestDto = PostUpdateRequestDto(
        title: post.title,
        content: post.content,
        imageData: post.imageUrl,
      );
      final response = await _dio.put(
        '$_baseUrl/api/post/$postId',
        data: requestDto.toJson(),
      );
      final Map<String, dynamic> responseData = response.data['body'];
      return PostDetailDto.fromJson(responseData).toModel();
    } on DioException catch (e) {
      throw _handleDioError(e, '게시글 수정');
    }
  }

  /*
   * 게시글을 삭제합니다.
   * API: DELETE /api/post/{postId}
   */
  Future<void> deletePost(String postId) async {
    try {
      await _dio.delete('$_baseUrl/api/post/$postId');
    } on DioException catch (e) {
      throw _handleDioError(e, '게시글 삭제');
    }
  }

  // ===================== 댓글 관련 =====================

  /*
   * 특정 게시글의 댓글 목록을 가져옵니다.
   * API: GET /api/posts/{postId}/replies
   */
  Future<List<Reply>> fetchRepliesForPost(String postId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/posts/$postId/replies');
      final List<dynamic> jsonList = response.data['body'];
      return jsonList.map((json) => ReplyDto.fromJson(json).toModel()).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, '댓글 목록 조회');
    }
  }

  /*
   * 새 댓글을 생성합니다.
   * API: POST /api/posts/{postId}/replies
   */
  Future<Reply> createReply(String postId, Reply reply) async {
    try {
      final replyDto = ReplyDto.fromModel(reply);
      final response = await _dio.post(
        '$_baseUrl/api/posts/$postId/replies',
        data: replyDto.toJson(),
      );
      final Map<String, dynamic> responseData = response.data['body'];
      return ReplyDto.fromJson(responseData).toModel();
    } on DioException catch (e) {
      throw _handleDioError(e, '댓글 작성');
    }
  }

  /*
   * 댓글을 수정합니다.
   * API: PUT /api/posts/replies/{replyId}
   */
  Future<Reply> updateReply(String postId, String replyId, Reply reply) async {
    try {
      final replyDto = ReplyDto.fromModel(reply);
      final response = await _dio.put(
        '$_baseUrl/api/posts/replies/$replyId',
        data: replyDto.toJson(),
      );
      final Map<String, dynamic> responseData = response.data['body'];
      return ReplyDto.fromJson(responseData).toModel();
    } on DioException catch (e) {
      throw _handleDioError(e, '댓글 수정');
    }
  }

  /*
   * 댓글을 삭제합니다.
   * API: DELETE /api/posts/replies/{replyId}
   */
  Future<void> deleteReply(String postId, String replyId) async {
    try {
      await _dio.delete('$_baseUrl/api/posts/replies/$replyId');
    } on DioException catch (e) {
      throw _handleDioError(e, '댓글 삭제');
    }
  }

/*
 * 게시물 좋아요를 토글합니다. (좋아요 추가/취소)
 * API: POST /api/posts/{postId}/like
 */
  Future<Map<String, dynamic>> togglePostLike(String postId) async {
    try {
      final response = await _dio.post('$_baseUrl/api/posts/$postId/like');
      return response.data['body']; // {postId, isLiked, likeCount} 반환
    } on DioException catch (e) {
      throw _handleDioError(e, '좋아요 처리');
    }
  }

  // ===================== 에러 처리 =====================

  Exception _handleDioError(DioException dioError, String operation) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('$operation 중 연결 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.');

      case DioExceptionType.badResponse:
        final statusCode = dioError.response?.statusCode;
        switch (statusCode) {
          case 400:
            return Exception('잘못된 요청입니다.');
          case 401:
            return Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
          case 403:
            return Exception('권한이 없습니다.');
          case 404:
            return Exception('요청하신 리소스를 찾을 수 없습니다.');
          case 500:
            return Exception('서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
          default:
            return Exception(
                '$operation 중 알 수 없는 오류가 발생했습니다 (코드: $statusCode)');
        }
      case DioExceptionType.cancel:
        return Exception('$operation 요청이 취소되었습니다.');
      case DioExceptionType.unknown:
        return Exception('네트워크에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.');
      default:
        return Exception('$operation 중 예상치 못한 오류가 발생했습니다: ${dioError.message}');
    }
  }
}
