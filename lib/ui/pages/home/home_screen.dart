import 'package:chakak_flutter/_core/constants/app_routes.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/banner_widget.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/photo_service_category_widget.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/photographer_card_list.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/service_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/banner.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/photo_service_category.dart';
import '../../../data/models/photographer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../photo_service/photo_service_detail_page.dart';
import '../profile/my_profile_page.dart';
import '../profile/photographer/photographer_profile_page.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = [
    HomeContent(),
    SearchScreen(),
    Center(child: Text("예약 화면", style: TextStyle(fontSize: 24))),
    MyProfilePage(), // PhotographerProfilePage에서 MyProfilePage로 변경
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      appBar: CustomAppbar(),
      body: _pages[currentIndex],
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  void _onCategoryTap(PhotoServiceCategory category) {
    print('카테고리 클릭: ${category.name}');
  }

  void _onBannerTap(BannerItem banner) {
    print('배너 클릭: ${banner.title}');
  }

  void _onServiceTap(BuildContext context, PhotoService service) {
    // PhotoServiceDetailPage로 네비게이션
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoServiceDetailPage(service: service),
      ),
    );
  }

  void _onPhotographerTap(BuildContext context, Photographer photographer) {
    // 포토그래퍼 클릭시 프로필 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotographerProfilePage(
          photographerId: photographer.id, // 포토그래퍼 ID 전달
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: 테스트용 나중에 지워야함
          ElevatedButton(
            onPressed: () {
              // 채팅방 ID 1번으로 입장 (테스트용)
              Navigator.pushNamed(context, AppRoutes.chat, arguments: 1);
            },
            child: const Text("채팅 테스트 (임시)"),
          ),
          const SizedBox(height: 16), // 버튼과 배너 사이 간격

          // 배너 영역
          BannerWidget(
            height: 180,
            autoSlideInterval: const Duration(seconds: 3),
            showIndicators: true,
            onBannerTap: _onBannerTap,
            margin: const EdgeInsets.all(16),
          ),

          // 카테고리
          PhotoServiceCategoryWidget(
            onCategoryTap: _onCategoryTap,
            showSeeAll: true,
          ),

          const SizedBox(height: 10),
          ServiceCardList(
            onServiceTap: (service) => _onServiceTap(context, service),
          ),
          const SizedBox(height: 24),
          PhotographerCardList(
            onPhotographerTap: (photographer) =>
                _onPhotographerTap(context, photographer),
          ),
        ],
      ),
    );
  }
}
