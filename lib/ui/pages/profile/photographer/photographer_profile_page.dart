import 'package:chakak_flutter/ui/pages/portfolio/portfolios_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../../provider/global/photoService/photo_service_provider.dart';
import '../../photo_service/widgets/photo_service_list_widget.dart';
import '../../photo_service/photo_service_detail_page.dart';
import 'widgets/photographer_reviews.dart';
import 'widgets/photographer_upper_profile.dart';

class PhotographerProfilePage extends ConsumerStatefulWidget {
  final int photographerId;

  const PhotographerProfilePage({
    super.key,
    required this.photographerId,
  });

  @override
  ConsumerState<PhotographerProfilePage> createState() =>
      _PhotographerProfilePageState();
}

class _PhotographerProfilePageState
    extends ConsumerState<PhotographerProfilePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 포토그래퍼의 서비스 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(photoServiceProvider.notifier)
          .loadServicesByPhotographer(widget.photographerId);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        title: const Text('포토그래퍼 프로필'),
      ),
      body: Column(
        children: [
          _buildProfileSection(),
          _buildTabBar(),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: PhotographerUpperProfile(photographerId: widget.photographerId),
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
          Tab(text: '서비스'),
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
          _buildServiceTab(),
          PortfolioPage(photographerId: widget.photographerId.toString()),
          _buildScrollableContent(const PhotographerReviews()),
        ],
      ),
    );
  }

  Widget _buildServiceTab() {
    // 포토그래퍼의 서비스 가져오기
    final services = ref
        .read(photoServiceProvider.notifier)
        .getPhotographerServices(widget.photographerId);

    if (services.isEmpty) {
      // 로딩 상태 확인
      final isLoading = ref.watch(photoServiceProvider).isLoading;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return const Center(child: Text('등록된 서비스가 없습니다.'));
      }
    }

    return PhotoServiceListWidget(
      services: services,
      onServiceTap: (service) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PhotoServiceDetailPage(service: service)));
      },
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
