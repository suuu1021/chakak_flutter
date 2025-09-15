import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../data/models/portfolio.dart';
// import '../../../providers/auth_provider.dart';
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
    return AppBar(
      title: Text(widget.portfolio.category),
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      actions: [
        // 수정 버튼 (소유자만 표시)
        if (_isOwner())
          IconButton(
            onPressed: _editPortfolio,
            icon: const Icon(Icons.edit_outlined),
          ),
        // 삭제 버튼 (소유자만 표시)
        if (_isOwner())
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

  bool _isOwner() {
    // final authState = ref.watch(authProvider);
    // return authState.when(
    //   data: (user) => user?.id == widget.portfolio.photographerId,
    //   loading: () => false,
    //   error: (_, __) => false,
    // );
    return true;
  }

  void _editPortfolio() {
    debugPrint('포트폴리오 수정: ${widget.portfolio.title}');
    // TODO: 수정 페이지로 이동
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
            onPressed: () {
              Navigator.of(context).pop();
              debugPrint('삭제 확인: ${widget.portfolio.title}');
              // TODO: 실제 삭제 로직
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
