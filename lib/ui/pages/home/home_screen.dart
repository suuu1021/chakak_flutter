import 'package:chakak_flutter/ui/pages/home/service_card_list.dart';
import 'package:flutter/material.dart';
import '../../../_core/constants/app_images.dart';
import '../../../_core/constants/app_strings.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../photoService/category_widgets.dart';
import '../profile/photographer/photographer_card_list.dart';
import '../profile/photographer/photographer_profile.dart';
import 'banner_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // 탭별 화면
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // 홈 화면 콘텐츠를 첫 페이지로 설정
    _pages.add(const HomeContent());
    _pages.add(
        const Center(child: Text("검색 화면", style: TextStyle(fontSize: 24))));
    _pages.add(
        const Center(child: Text("예약 화면", style: TextStyle(fontSize: 24))));
    _pages.add(const PhotographerProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(),
      body: _pages[_currentIndex],
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
