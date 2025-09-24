import 'package:chakak_flutter/ui/pages/portfolio/portfolios_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../../data/models/photo_service/photo_service.dart';
import '../../../../provider/global/photoService/photo_service_provider.dart';
import '../../photo_service/widgets/photo_service_list_widget.dart';
import '../../photo_service/photo_service_detail_page.dart';
import 'widgets/photographer_upper_profile.dart';
import 'widgets/photographer_reviews_section.dart'; // ✅ 추가한 리뷰 섹션 임포트

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
  // SingleTickerProviderStateMixin 추가
  late TabController _tabController; // late 키워드 사용

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 즉시 로딩 시작
    ref
        .read(photoServiceProvider.notifier)
        .loadServicesByPhotographer(widget.photographerId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // 페이지를 떠날 때 photoServiceProvider의 상태를 초기화하는 로직 추가
    ref.read(photoServiceProvider.notifier).clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(photoServiceProvider);

    // 로딩 중이고 데이터가 비어있을 때만 로딩 표시
    if (serviceState.isLoading && serviceState.services.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          title: const Text('포토그래퍼 프로필'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
    final serviceState = ref.watch(photoServiceProvider);
    final services = serviceState.services
        .where((service) => service.photographerId == widget.photographerId)
        .cast<PhotoService>()
        .toList();
    final isLoading = serviceState.isLoading;

    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildServiceTab(services, isLoading),
          PortfolioPage(photographerId: widget.photographerId.toString()),
          _buildReviewTab(services, isLoading), // ✅ 리뷰 탭
        ],
      ),
    );
  }

  Widget _buildServiceTab(List<PhotoService> services, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (services.isEmpty) {
      return const Center(child: Text('등록된 서비스가 없습니다.'));
    }

    return PhotoServiceListWidget(
      services: services,
      onServiceTap: (service) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoServiceDetailPage(
              service: service,
              otherServices: services.where((s) => s.id != service.id).toList(),
            ),
          ),
        );
      },
    );
  }

  /// ✅ 리뷰 탭 (포토그래퍼 전체 리뷰 표시)
  Widget _buildReviewTab(List<PhotoService> services, bool isLoading) {
    if (isLoading) {
      return _buildScrollableContent(
          const Center(child: CircularProgressIndicator()));
    }

    return _buildScrollableContent(
      PhotographerReviewsSection(photographerId: widget.photographerId),
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
