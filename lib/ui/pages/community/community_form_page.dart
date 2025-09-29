import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../_core/constants/app_colors.dart';
import '../../../data/models/community/post.dart';
import '../../../provider/community/community_repository_provider.dart';
import '../../../provider/community/post_provider.dart';

/*
 * 커뮤니티 게시글 등록/수정 페이지
 * 기존 UI 스타일을 유지하면서 실제 Provider와 연동하여 게시글을 등록
 */
class CommunityFormPage extends ConsumerStatefulWidget {
  final String? postId; // null이면 새 글 작성, 값이 있으면 수정

  const CommunityFormPage({
    super.key,
    this.postId,
  });

  @override
  ConsumerState<CommunityFormPage> createState() => _CommunityFormPageState();
}

class _CommunityFormPageState extends ConsumerState<CommunityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 수정 모드인 경우 기존 데이터 로드
    if (widget.postId != null) {
      _loadPostData();
    }
  }

  /*
   * 수정할 게시글 데이터 로드 (수정 모드)
   */
  void _loadPostData() {}

  /*
   * 폼 유효성 검사
   */
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showErrorMessage('제목을 입력해주세요.');
      return false;
    }

    if (content.isEmpty) {
      _showErrorMessage('내용을 입력해주세요.');
      return false;
    }

    return true;
  }

  /*
   * 게시글 등록/수정 처리
   */
  Future<void> _submitPost() async {
    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      if (widget.postId == null) {
        // 새 게시글 등록
        final newPost = Post(
          id: '',
          title: title,
          author: '',
          authorId: '',
          content: content,
          timeAgo: '',
        );
        await ref.read(postProvider.notifier).createPost(newPost);
        _showSuccessMessage('게시글이 등록되었습니다.');
      } else {
        // 기존 게시글 수정
        final repository = ref.read(communityRepositoryProvider);
        final existingPost = await repository.fetchPostById(widget.postId!);
        final updatedPost =
            existingPost.copyWith(title: title, content: content);
        await ref
            .read(postProvider.notifier)
            .updatePost(widget.postId!, updatedPost);
        _showSuccessMessage('게시글이 수정되었습니다.');
      }

      // 성공 시 이전 화면으로 돌아가기
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      _showErrorMessage('${_isEditMode ? '수정' : '등록'} 중 오류가 발생했습니다: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /*
   * 수정 모드 여부 확인
   */
  bool get _isEditMode => widget.postId != null;

  /*
   * 성공 메시지 표시
   */
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /*
   * 에러 메시지 표시
   */
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /*
   * 작성 취소 확인 다이얼로그
   */
  Future<bool> _showCancelDialog() async {
    // 내용이 비어있으면 바로 뒤로가기
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('작성 취소'),
        content: const Text('작성 중인 내용이 있습니다. 정말 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('계속 작성'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldPop = await _showCancelDialog();
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () async {
              final shouldPop = await _showCancelDialog();
              if (shouldPop && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            _isEditMode ? '게시글 수정' : '게시글 작성',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _submitPost,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : const Text(
                      '완료',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // 로딩 인디케이터
              if (_isSubmitting)
                const LinearProgressIndicator(
                  backgroundColor: AppColors.gray100,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),

              // 입력 폼
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 입력 필드
                      TextFormField(
                        controller: _titleController,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          labelText: '제목',
                          hintText: '제목을 입력해주세요',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                        maxLength: 100,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // 내용 입력 필드
                      TextFormField(
                        controller: _contentController,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          labelText: '내용',
                          hintText: '내용을 입력해주세요',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 10,
                        minLines: 5,
                        maxLength: 1000,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '내용을 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // 작성 가이드
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '작성 가이드',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.gray800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• 사진작가 추천, 촬영 장소, 후기 등을 공유해주세요\n'
                              '• 다른 사용자에게 도움이 되는 내용으로 작성해주세요\n'
                              '• 욕설이나 비방글은 삭제될 수 있습니다',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
