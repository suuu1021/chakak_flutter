import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../data/models/portfolio.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/global/portfolio/portfolio_notifier.dart';
import 'portfolio_form_page.dart';
import 'widgets/portfolio_image_gallery.dart';
import 'widgets/portfolio_content_section.dart';

class PortfolioDetailPage extends ConsumerStatefulWidget {
  final Portfolio portfolio;

  const PortfolioDetailPage({
    super.key,
    required this.portfolio,
  });

  @override
  ConsumerState<PortfolioDetailPage> createState() =>
      _PortfolioDetailPageState();
}

class _PortfolioDetailPageState extends ConsumerState<PortfolioDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PortfolioImageGallery(imageUrls: widget.portfolio.imageUrls),
            PortfolioContentSection(portfolio: widget.portfolio),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final bool isOwner = _isOwner(ref);

    return AppBar(
      title: Text(widget.portfolio.category),
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      actions: [
        // 수정 버튼 (소유자만 표시)
        if (isOwner)
          IconButton(
            onPressed: _editPortfolio,
            icon: const Icon(Icons.edit_outlined),
          ),
        // 삭제 버튼 (소유자만 표시)
        if (isOwner)
          IconButton(
            onPressed: _deletePortfolio,
            icon: const Icon(Icons.delete_outlined),
          ),
        // 공유 버튼
        IconButton(
          onPressed: _sharePortfolio,
          icon: const Icon(Icons.share_outlined),
        ),
      ],
    );
  }

  bool _isOwner(WidgetRef ref) {
    final authState = ref.watch(authProvider);
    print('현재 로그인 userId: ${authState.login?.userId}');
    print('현재 포트폴리오 photographerId: ${widget.portfolio.photographerProfileId}');

    return authState.login?.userId.toString() ==
        widget.portfolio.photographerUserId;
  }

  void _editPortfolio() async {
    debugPrint('포트폴리오 수정: ${widget.portfolio.title}');

    // 수정 페이지로 이동하며 기존 포트폴리오 데이터를 전달합니다.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PortfolioFormPage(
          portfolio: widget.portfolio,
        ),
      ),
    );

    // 수정 완료 후 true를 반환받으면 포트폴리오 목록을 새로고침합니다.
    if (result == true) {
      debugPrint('포트폴리오 수정 완료');
      // 개별 포트폴리오 다시 로드 (디테일 페이지용)
      await ref
          .read(portfolioProvider.notifier)
          .selectPortfolio(widget.portfolio.id);
    }
  }

  void _deletePortfolio() {
    debugPrint('포트폴리오 삭제: ${widget.portfolio.title}');
    _showDeleteConfirmDialog();
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('포트폴리오 삭제'),
        content: Text('${widget.portfolio.title}을(를) 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final apiService =
                    ref.read(portfolioProvider.notifier); // API 서비스
                await apiService
                    .deletePortfolio(widget.portfolio.id.toString());

                // 삭제 성공 시
                debugPrint('포트폴리오 삭제 성공');
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(true); // 이전 페이지로 돌아가며 true 반환
              } catch (e) {
                // 삭제 실패 시 에러 메시지 출력
                debugPrint('포트폴리오 삭제 실패: $e');
                Navigator.of(context).pop(); // 다이얼로그 닫기
                // 사용자에게 오류 메시지를 보여주는 스낵바 또는 다이얼로그 추가
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('삭제에 실패했습니다: ${e.toString()}')),
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _sharePortfolio() {
    final shareText =
        '${widget.portfolio.title}\n\n${widget.portfolio.description}\n\n'
        'https://myapp.com/portfolio/${widget.portfolio.id}';
    Share.share(shareText);
  }
}
