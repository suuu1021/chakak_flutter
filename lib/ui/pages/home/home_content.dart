import 'package:chakak_flutter/ui/pages/home/photo_service_category_widget.dart';
import 'package:chakak_flutter/ui/pages/home/photographer_card_list.dart';
import 'package:chakak_flutter/ui/pages/home/service_card_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/banner.dart';
import '../../../data/models/photo_service.dart';
import '../../../data/models/photo_service_category.dart';
import '../../../data/models/photographer.dart';
import 'banner_widget.dart';

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  void _onCategoryTap(PhotoServiceCategory category) {
    print('카테고리 클릭: ${category.name}');
  }

  void _onBannerTap(BannerItem banner) {
    print('배너 클릭: ${banner.title}');
  }

  void _onServiceTap(PhotoService service) {
    print('포토 서비스 클릭 : ${service.title}');
  }

  void _onPhotographerTap(Photographer photographer) {
    print('포토그래퍼 클릭 : ${photographer.businessName}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
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
            onCategoryTap: _onCategoryTap,
            showSeeAll: true,
          ),

          const SizedBox(height: 10),
          ServiceCardList(
            onServiceTap: _onServiceTap,
          ),
          const SizedBox(height: 24),
          PhotographerCardList(
            onPhotographerTap: _onPhotographerTap,
          ),
        ],
      ),
    );
  }
}
