import '../banner.dart';

abstract class BannerRepository {
  Future<List<BannerItem>> getActiveBanners();

  Future<void> trackBannerClick(int bannerId);
}

class BannerRepositoryImpl implements BannerRepository {
  @override
  Future<List<BannerItem>> getActiveBanners() async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500));

    final mockData = [
      BannerItem(
        id: 1,
        title: '스페셜 촬영 이벤트',
        subtitle: '지금 예약하면 50% 할인!',
        imageUrl: 'https://picsum.photos/400/200?random=1',
        linkUrl: '/event/special-photo',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      BannerItem(
        id: 2,
        title: '웨딩 촬영 패키지',
        subtitle: '평생 간직할 순간을 담아드립니다',
        imageUrl: 'https://picsum.photos/400/200?random=2',
        linkUrl: '/services/wedding',
        createdAt: DateTime.now(),
      ),
      BannerItem(
        id: 3,
        title: '프로필 촬영',
        subtitle: '당신만의 특별한 모습을',
        imageUrl: 'https://picsum.photos/400/200?random=3',
        linkUrl: '/services/profile',
        createdAt: DateTime.now(),
      ),
    ];

    return mockData;
  }

  @override
  Future<void> trackBannerClick(int bannerId) async {
    // TODO: 실제 API 호출로 교체
    print('배너 클릭 추적: $bannerId');
  }
}
