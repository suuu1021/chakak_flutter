import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/banner.dart';
import '../../data/models/_repositories/banner_repository.dart';

class BannerState {
  final List<BannerItem> banners;
  final bool isLoading;
  final String? error;

  BannerState({
    this.banners = const [],
    this.isLoading = false,
    this.error,
  });

  BannerState copyWith({
    List<BannerItem>? banners,
    bool? isLoading,
    String? error,
  }) {
    return BannerState(
      banners: banners ?? this.banners,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 창고 메뉴얼
class BannerNotifier extends Notifier<BannerState> {
  late BannerRepository _repository;

  BannerRepository get repository => _repository;

  @override
  BannerState build() {
    _repository = BannerRepositoryImpl();

    return BannerState();
  }

  Future<void> loadBanners() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final banners = await _repository.getActiveBanners();
      state = state.copyWith(banners: banners, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> trackBannerClick(int bannerId) async {
    try {
      await _repository.trackBannerClick(bannerId);
    } catch (e) {
      print('배너 클릭 추적 실패: $e');
    }
  }

  // 배너 새로고침
  Future<void> refreshBanners() async {
    await loadBanners();
  }

  // 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// 실제 창고 개설
final bannerProvider = NotifierProvider<BannerNotifier, BannerState>(
  () => BannerNotifier(),
);
