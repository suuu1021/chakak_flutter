import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../data/models/portfolio.dart';
import '../../../provider/global/portfolio/portfolio_notifier.dart';
import 'portfolio_detail_page.dart';
import 'portfolio_form_page.dart';
import 'widgets/portfolio_card_widget.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(portfolioState.portfolios),
              const SizedBox(height: AppSizes.spacing12),
              Expanded(
                child: _buildContent(context, ref, portfolioState),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddPortfolio(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(List<Portfolio> portfolios) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '포트폴리오',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${portfolios.length}개 작품',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, PortfolioState state) {
    // 에러 상태
    if (state.errorMessage != null) {
      return _buildErrorView(context, ref, state.errorMessage!);
    }

    // 로딩 상태
    if (state.isLoading) {
      return _buildLoadingView();
    }

    // 빈 목록
    if (state.portfolios.isEmpty) {
      return _buildEmptyView();
    }

    // 포트폴리오 목록
    return _buildPortfolioList(context, state.portfolios);
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSizes.spacing16),
          Text(
            '포트폴리오를 불러오는 중...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
      BuildContext context, WidgetRef ref, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            '포트폴리오를 불러올 수 없습니다',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacing24),
          ElevatedButton.icon(
            onPressed: () => _onRetry(ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          SizedBox(height: AppSizes.spacing16),
          Text(
            '아직 포트폴리오가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.spacing8),
          Text(
            '첫 번째 작품을 등록해보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioList(BuildContext context, List<Portfolio> portfolios) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      child: ListView.separated(
        itemCount: portfolios.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSizes.spacing12),
        itemBuilder: (context, index) => PortfolioCardWidget(
          portfolio: portfolios[index],
          onTap: () => _onPortfolioTap(context, portfolios[index]),
        ),
      ),
    );
  }

  void _onPortfolioTap(BuildContext context, Portfolio portfolio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PortfolioDetailPage(portfolio: portfolio),
      ),
    );
  }

  void _onAddPortfolio(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const PortfolioFormPage(),
      ),
    );

    // 등록 성공 시 리스트 새로고침
    if (result == true) {
      debugPrint('포트폴리오 등록 완료');
      await ref.read(portfolioProvider.notifier).loadPortfolios();
    }
  }

  void _onRetry(WidgetRef ref) {
    ref.read(portfolioProvider.notifier).clearError();
    ref.read(portfolioProvider.notifier).loadPortfolios();
  }

  Future<void> _onRefresh(BuildContext context) async {
    final ref = ProviderScope.containerOf(context);
    await ref.read(portfolioProvider.notifier).loadPortfolios();
  }
}
