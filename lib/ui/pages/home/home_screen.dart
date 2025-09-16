import 'package:chakak_flutter/ui/pages/chat/chat_list_screen.dart';
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
import '../photo_service/category_service_list_page.dart';
import '../photo_service/photo_service_detail_page.dart';
import '../profile/user/my_profile_page.dart';
import '../profile/photographer/photographer_profile_page.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = [
    HomeContent(),
    SearchScreen(),
    Center(child: Text("커뮤니티 화면", style: TextStyle(fontSize: 24))),
    ChatListScreen(),
    MyProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      appBar: CustomAppbar(),
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _onCategoryTap(BuildContext context, PhotoServiceCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryServiceListPage(category: category),
      ),
    );
  }

  void _onBannerTap(BannerItem banner) {
    print('배너 클릭: ${banner.title}');
  }

  void _onServiceTap(BuildContext context, PhotoService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoServiceDetailPage(service: service),
      ),
    );
  }

  void _onPhotographerTap(BuildContext context, Photographer photographer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotographerProfilePage(
          photographerId: photographer.id,
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      Future.delayed(Duration(milliseconds: 500)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              height: 120,
              onCategorySelected: (category) =>
                  _onCategoryTap(context, category),
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
      ),
    );
  }
}