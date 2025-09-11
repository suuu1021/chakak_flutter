import 'package:chakak_flutter/ui/pages/home/service_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../photoService/category_widgets.dart';
import '../profile/photographer/photographer_profile_page.dart';
import 'banner_widget.dart';
import 'photographer_card_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = [
    HomeContent(),
    Center(child: Text("검색 화면", style: TextStyle(fontSize: 24))),
    Center(child: Text("예약 화면", style: TextStyle(fontSize: 24))),
    PhotographerProfilePage(),
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

// ---------------- 홈 화면 콘텐츠 ----------------
class HomeContent extends StatelessWidget {
  void _onCategoryTap(CategoryItem category) {
    print('카테고리 선택: ${category.name}');
  }

  void _onBannerTap(BannerItem banner) {
    print('배너 클릭: ${banner.title}');
  }

  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 배너 영역
          BannerWidget(
            height: 180,
            autoSlideInterval: Duration(seconds: 3),
            showIndicators: true,
            onBannerTap: _onBannerTap,
            margin: EdgeInsets.all(16),
          ),

          // 카테고리
          CategoryWidgets(
            categories: CategoryItem.photoServiceCategories(),
            onCategoryTap: _onCategoryTap,
            showSeeAll: true,
          ),

          const SizedBox(height: 10),
          ServiceCardList(),
          SizedBox(height: 24),
          PhotographerCardList(),
        ],
      ),
    );
  }
}
