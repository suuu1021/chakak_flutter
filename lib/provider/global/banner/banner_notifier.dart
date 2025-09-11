
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/banner.dart';
import '../../../data/models/repositories/banner_repository.dart';
import 'banner_api_service.dart';

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  return BannerRepositoryImpl();
});

// API Service Provider
final bannerApiServiceProvider = Provider<BannerApiService>((ref) {
  final repository = ref.read(bannerRepositoryProvider);
  return BannerApiService(repository);
});

// State 클래스
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

// Notifier 클래스
class BannerNotifier extends StateNotifier<BannerState> {
  final BannerApiService _apiService;

  BannerNotifier(this._apiService) : super(BannerState());

  Future<void> loadBanners() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final banners = await _apiService.getActiveBanners();
      state = state.copyWith(banners: banners, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> trackBannerClick(int bannerId) async {
    try {
      await _apiService.trackBannerClick(bannerId);
    } catch (e) {
      print('배너 클릭 추적 실패: $e');
    }
  }
}

// Provider
final bannerNotifierProvider =
    StateNotifierProvider<BannerNotifier, BannerState>((ref) {
  final apiService = ref.read(bannerApiServiceProvider);
  return BannerNotifier(apiService);
});
