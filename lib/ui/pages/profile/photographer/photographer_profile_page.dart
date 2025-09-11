import 'package:chakak_flutter/ui/pages/portfolio/portfolios_page.dart';
import 'package:flutter/material.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import 'photographer_portfolios.dart';
import 'photographer_price_options.dart';
import 'photographer_reviews.dart';
import 'photographer_upper_profile.dart';

class PhotographerProfilePage extends StatefulWidget {
  const PhotographerProfilePage({super.key});

  @override
  State<PhotographerProfilePage> createState() =>
      _PhotographerProfilePageState();
}

class _PhotographerProfilePageState extends State<PhotographerProfilePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileSection(),
        _buildTabBar(),
        _buildTabContent(),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: const PhotographerUpperProfile(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.gray500,
        indicatorWeight: 2.0,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: '가격 옵션'),
          Tab(text: '포트폴리오'),
          Tab(text: '리뷰'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildScrollableContent(const PhotographerPriceOptions()),
          const PortfolioPage(),
          _buildScrollableContent(const PhotographerReviews()),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      physics: const ClampingScrollPhysics(),
      child: child,
    );
  }
}
