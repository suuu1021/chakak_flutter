import 'package:chakak_flutter/ui/pages/portfolio/portfolios_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../../data/models/photo_service/photo_service.dart';
import '../../../../provider/auth/session_provider.dart';
import '../../../../provider/global/photoService/photo_service_provider.dart';
import '../../photo_service/photo_service_form_page.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    ref
        .read(photoServiceProvider.notifier)
        .loadServicesByPhotographer(widget.photographerId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(photoServiceProvider);
    final session = ref.watch(sessionProvider);

    // 포트폴리오와 동일한 패턴으로 서비스 필터링
    final services = serviceState.services
        .where((service) => service.photographerId == widget.photographerId)
        .cast<PhotoService>()
        .toList();

    // 포트폴리오와 동일한 디버깅 로그
    print("=== PhotoServicePage 디버깅 ===");
    print("session.isLogin: ${session.isLogin}");
    print("session.userId: ${session.userId}");
    print("session.userTypeCode: ${session.userTypeCode}");
    print("widget.photographerId: ${widget.photographerId}");
    print("services.length: ${services.length}");

    // 서비스가 있을 때 첫 번째 서비스의 소유자 ID 확인 (포트폴리오와 동일)
    String? serviceOwnerUserId;
    if (services.isNotEmpty) {
      serviceOwnerUserId = services.first.photographerUserId.toString();
      print("serviceOwnerUserId: $serviceOwnerUserId");
    }

    // 포트폴리오와 완전히 동일한 로직
    final isMyProfile = session.isLogin &&
        session.userTypeCode?.toLowerCase() == 'photographer' &&
        serviceOwnerUserId != null &&
        session.userId.toString() == serviceOwnerUserId;

    print("각 조건 체크:");
    print("  session.isLogin: ${session.isLogin}");
    print(
        "  session.userTypeCode?.toLowerCase() == 'photographer': ${session.userTypeCode?.toLowerCase() == 'photographer'}");
    print("  serviceOwnerUserId != null: ${serviceOwnerUserId != null}");
    print(
        "  session.userId.toString() == serviceOwnerUserId: ${session.userId.toString() == serviceOwnerUserId}");
    print("최종 isMyProfile: $isMyProfile");
    print("====================================");

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
          _buildTabContent(isMyProfile, services), // services 전달
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

  // services를 파라미터로 받아서 중복 필터링 제거
  Widget _buildTabContent(bool isMyProfile, List<PhotoService> services) {
    final serviceState = ref.watch(photoServiceProvider);
    final isLoading = serviceState.isLoading;

    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildServiceTab(services, isLoading, isMyProfile),
          PortfolioPage(photographerId: widget.photographerId.toString()),
          _buildReviewTab(services, isLoading),
        ],
      ),
    );
  }

  Widget _buildServiceTab(
      List<PhotoService> services, bool isLoading, bool isMyProfile) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        if (services.isEmpty)
          const Center(child: Text('등록된 서비스가 없습니다.'))
        else
          PhotoServiceListWidget(
            services: services,
            onServiceTap: (service) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoServiceDetailPage(
                    service: service,
                    otherServices:
                        services.where((s) => s.id != service.id).toList(),
                  ),
                ),
              );
            },
          ),
        // 포트폴리오와 동일: isMyProfile일 때만 + 버튼 표시
        if (isMyProfile)
          Positioned(
            right: AppSizes.spacing16,
            bottom: AppSizes.spacing16,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoServiceFormPage(
                      photographerId: widget.photographerId,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewTab(List<PhotoService> services, bool isLoading) {
    if (isLoading) {
      return _buildScrollableContent(
          const Center(child: CircularProgressIndicator()));
    }

    if (services.isEmpty) {
      return _buildScrollableContent(
          const Center(child: Text('등록된 서비스가 없어 리뷰를 표시할 수 없습니다.')));
    }

    return _buildScrollableContent(
        PhotographerReviews(serviceId: services.first.id));
  }

  Widget _buildScrollableContent(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      physics: const ClampingScrollPhysics(),
      child: child,
    );
  }
}
