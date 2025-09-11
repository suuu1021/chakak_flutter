import 'package:flutter/material.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../data/models/portfolio.dart';
import 'portfolio_detail_page.dart';
import 'portfolio_form_page.dart';
import 'widgets/portfolio_card_widget.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List<Portfolio> portfolios = List.from(Portfolio.samplePortfolios);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSizes.spacing12),
              Expanded(
                child: _buildPortfolioList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddPortfolio(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
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

  Widget _buildPortfolioList() {
    return ListView.separated(
      itemCount: portfolios.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSizes.spacing12),
      itemBuilder: (context, index) => PortfolioCardWidget(
        portfolio: portfolios[index],
        onTap: () => _onPortfolioTap(context, portfolios[index]),
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
      // TODO: 실제로는 서버에서 새 데이터를 가져와야 함
      setState(() {
        // 임시로 샘플 데이터 새로고침
        portfolios = List.from(Portfolio.samplePortfolios);
      });
    }
  }
}
