import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../data/models/portfolio.dart';
import '../../../provider/auth/session_provider.dart';
import '../../../provider/global/portfolio/portfolio_notifier.dart';
import 'portfolio_detail_page.dart';
import 'portfolio_form_page.dart';
import 'widgets/portfolio_card_widget.dart';

class PortfolioPage extends ConsumerStatefulWidget {
  final String? photographerId;

  const PortfolioPage({
    super.key,
    this.photographerId,
  });

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  @override
  void initState() {
    super.initState();

    print('=== PortfolioPage initState ===');
    print('photographerId: ${widget.photographerId}');
    print('photographerId != null: ${widget.photographerId != null}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.photographerId != null) {
        // String을 int로 변환해서 전달
        final photographerIdInt = int.tryParse(widget.photographerId!);
        if (photographerIdInt != null) {
          ref
              .read(portfolioProvider.notifier)
              .loadPortfoliosByPhotographer(widget.photographerId!);
        } else {
          print('photographerId 변환 실패: ${widget.photographerId}');
          // 변환 실패 시 에러 처리 또는 기본 동작
        }
      } else {
        ref.read(portfolioProvider.notifier).loadPortfolios();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioProvider);
    final session = ref.watch(sessionProvider);

    // 디버깅을 위한 로그
    print("=== PortfolioPage 디버깅 ===");
    print("session.isLogin: ${session.isLogin}");
    print("session.userId: ${session.userId}");
    print("session.userTypeCode: ${session.userTypeCode}");
    print("widget.photographerId: ${widget.photographerId}");
    print(
        "portfolioState.portfolios.length: ${portfolioState.portfolios.length}");

    // 포트폴리오가 있을 때 첫 번째 포트폴리오의 소유자 ID 확인
    String? portfolioOwnerUserId;
    if (portfolioState.portfolios.isNotEmpty) {
      portfolioOwnerUserId = portfolioState.portfolios.first.photographerUserId;
      print("portfolioOwnerUserId: $portfolioOwnerUserId");
    }

    // 자신의 포트폴리오인지 확인
    final isMyPortfolio = session.isLogin &&
        session.userTypeCode?.toLowerCase() == 'photographer' &&
        portfolioOwnerUserId != null &&
        session.userId.toString() == portfolioOwnerUserId;

    print("각 조건 체크:");
    print("  session.isLogin: ${session.isLogin}");
    print(
        "  session.userTypeCode?.toLowerCase() == 'photographer': ${session.userTypeCode?.toLowerCase() == 'photographer'}");
    print("  portfolioOwnerUserId != null: ${portfolioOwnerUserId != null}");
    print(
        "  session.userId.toString() == portfolioOwnerUserId: ${session.userId.toString() == portfolioOwnerUserId}");
    print("최종 isMyPortfolio: $isMyPortfolio");
    print("====================================");

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(portfolioState),
              const SizedBox(height: AppSizes.spacing12),
              Expanded(
                child: _buildContent(context, portfolioState),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isMyPortfolio
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () => _onAddPortfolio(context),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHeader(PortfolioState state) {
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
          '${state.portfolios.length}/${state.totalElements}개 작품', // 수정
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, PortfolioState state) {
    // 에러 상태
    if (state.errorMessage != null && state.portfolios.isEmpty) {
      return _buildErrorView(context, state.errorMessage!);
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
    return _buildPortfolioListWithInfiniteScroll(context, state);
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

  Widget _buildErrorView(BuildContext context, String errorMessage) {
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
            onPressed: () => _onRetry(),
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

  // 기존 _buildPortfolioList 메서드 전체를 아래로 교체:
  Widget _buildPortfolioListWithInfiniteScroll(
      BuildContext context, PortfolioState state) {
    final itemCount = state.portfolios.length + 1; // 항상 +1 (메시지용)

    print('=== ListView 구성 ===');
    print('포트폴리오 수: ${state.portfolios.length}');
    print('hasNextPage: ${state.hasNextPage}');
    print('isLoadingMore: ${state.isLoadingMore}');
    print('최종 itemCount: $itemCount');

    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 200) {
            _loadMoreIfNeeded();
          }
          return false;
        },
        child: ListView.separated(
          itemCount: itemCount, // 변수 사용
          separatorBuilder: (context, index) =>
              index >= state.portfolios.length - 1
                  ? const SizedBox.shrink()
                  : const SizedBox(height: AppSizes.spacing12),
          itemBuilder: (context, index) {
            if (index < state.portfolios.length) {
              return PortfolioCardWidget(
                portfolio: state.portfolios[index],
                onTap: () => _onPortfolioTap(context, state.portfolios[index]),
              );
            }

            print('=== itemBuilder에서 하단 상태 확인 ===');
            print('현재 index: $index, 포트폴리오 수: ${state.portfolios.length}');
            print('isLoadingMore: ${state.isLoadingMore}');
            print('hasNextPage: ${state.hasNextPage}');

            return _buildBottomLoading(state);
          },
        ),
      ),
    );
  }

  void _onPortfolioTap(BuildContext context, Portfolio portfolio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PortfolioDetailPage(portfolioId: portfolio.id),
      ),
    );
  }

  void _onAddPortfolio(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const PortfolioFormPage(),
      ),
    );

    // 등록 성공 시 리스트 새로고침
    if (result == true) {
      debugPrint('포트폴리오 등록 완료');

      // photographerId에 따라 다른 메서드 호출
      if (widget.photographerId != null) {
        await ref
            .read(portfolioProvider.notifier)
            .loadPortfoliosByPhotographer(widget.photographerId!);
      } else {
        await ref.read(portfolioProvider.notifier).loadPortfolios();
      }
    }
  }

  void _onRetry() {
    ref.read(portfolioProvider.notifier).clearError();

    // photographerId에 따라 다른 메서드 호출
    if (widget.photographerId != null) {
      ref
          .read(portfolioProvider.notifier)
          .loadPortfoliosByPhotographer(widget.photographerId!);
    } else {
      ref.read(portfolioProvider.notifier).loadPortfolios();
    }
  }

  Widget _buildBottomLoading(PortfolioState state) {
    print('=== 하단 로딩 상태 확인 ===');
    print('isLoadingMore: ${state.isLoadingMore}');
    print('hasNextPage: ${state.hasNextPage}');

    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.spacing16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return state.hasNextPage
        ? const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('스크롤하여 더 보기')))
        : const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('모든 작품을 확인했습니다')));
  }

  void _loadMoreIfNeeded() {
    final state = ref.read(portfolioProvider);
    if (!state.isLoadingMore && state.hasNextPage) {
      ref.read(portfolioProvider.notifier).loadMorePortfolios();
    }
  }

  Future<void> _onRefresh(BuildContext context) async {
    // photographerId에 따라 다른 메서드 호출
    if (widget.photographerId != null) {
      await ref
          .read(portfolioProvider.notifier)
          .loadPortfoliosByPhotographer(widget.photographerId!);
    } else {
      await ref.read(portfolioProvider.notifier).loadPortfolios();
    }
  }
}
