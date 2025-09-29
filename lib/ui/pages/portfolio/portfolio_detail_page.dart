import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../data/models/portfolio/portfolio.dart';
import '../../../provider/auth/auth_provider.dart';
import '../../../provider/portfolio/portfolio_notifier.dart';
import 'portfolio_form_page.dart';
import 'widgets/portfolio_image_gallery.dart';
import 'widgets/portfolio_content_section.dart';

class PortfolioDetailPage extends ConsumerStatefulWidget {
  final String portfolioId;

  const PortfolioDetailPage({
    super.key,
    required this.portfolioId,
  });

  @override
  ConsumerState<PortfolioDetailPage> createState() =>
      _PortfolioDetailPageState();
}

class _PortfolioDetailPageState extends ConsumerState<PortfolioDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(portfolioProvider.notifier).selectPortfolio(widget.portfolioId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioProvider);
    final portfolio = portfolioState.selectedPortfolio;

    if (portfolio == null || portfolio.id != widget.portfolioId) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(portfolio),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PortfolioImageGallery(imageUrls: portfolio.imageUrls),
            PortfolioContentSection(portfolio: portfolio),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Portfolio portfolio) {
    final bool isOwner = _isOwner(ref, portfolio);

    return AppBar(
      title: Text(portfolio.category),
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      actions: [
        if (isOwner)
          IconButton(
            onPressed: () => _editPortfolio(portfolio),
            icon: const Icon(Icons.edit_outlined),
          ),
        if (isOwner)
          IconButton(
            onPressed: () => _deletePortfolio(portfolio),
            icon: const Icon(Icons.delete_outlined),
          ),
        IconButton(
          onPressed: () => _sharePortfolio(portfolio),
          icon: const Icon(Icons.share_outlined),
        ),
      ],
    );
  }

  bool _isOwner(WidgetRef ref, Portfolio portfolio) {
    final authState = ref.watch(authProvider);
    return authState.login?.userId.toString() == portfolio.photographerUserId;
  }

  void _editPortfolio(Portfolio portfolio) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PortfolioFormPage(portfolio: portfolio),
      ),
    );

    if (result == true) {
      // 수정 완료 후 데이터 다시 로드
      ref.read(portfolioProvider.notifier).selectPortfolio(widget.portfolioId);
    }
  }

  void _deletePortfolio(Portfolio portfolio) {
    _showDeleteConfirmDialog(portfolio);
  }

  void _showDeleteConfirmDialog(Portfolio portfolio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('포트폴리오 삭제'),
        content: Text('${portfolio.title}을(를) 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(portfolioProvider.notifier)
                    .deletePortfolio(portfolio.id);
                if (mounted) {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(true); // 이전 페이지로 돌아가며 성공 알림
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제에 실패했습니다: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _sharePortfolio(Portfolio portfolio) {
    final shareText = '${portfolio.title}\n\n${portfolio.description}\n\n'
        'https://myapp.com/portfolio/${portfolio.id}';
    Share.share(shareText);
  }
}
