import 'package:chakak_flutter/ui/pages/home/banner_widget.dart';
import 'package:chakak_flutter/ui/pages/home/photographer_card_list.dart';
import 'package:chakak_flutter/ui/pages/home/service_card_list.dart';
import 'package:flutter/material.dart';

import '../photoService/photo_service_category.dart';

class HomeContent extends StatelessWidget {
  void _onCategoryTap(CategoryItem category) {
    print('카테고리 클릭: ${category.name}');
  }

  void _onBannerTap(BannerItem banner) {
    print('배너 클릭: ${banner.title}');
  }

  void _onServiceTap(ServiceItem service) {
    print('포토 서비스 클릭 : ${service.title}');
  }

  void _onPhotographerTap(PhotographerItem photographer) {
    print('포토그래퍼 클릭 : ${photographer.businessName}');
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
          PhotoServiceCategory(
            categories: CategoryItem.photoServiceCategories(),
            onCategoryTap: _onCategoryTap,
            showSeeAll: true,
          ),

          const SizedBox(height: 10),
          ServiceCardList(
            onServiceTap: _onServiceTap,
          ),
          SizedBox(height: 24),
          PhotographerCardList(
            onPhotographerTap: _onPhotographerTap,
          ),
        ],
      ),
    );
  }
}
