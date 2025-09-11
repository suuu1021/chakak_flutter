import '../../../data/models/banner.dart';
import '../../../data/models/repositories/banner_repository.dart';

class BannerApiService {
  final BannerRepository _repository;

  BannerApiService(this._repository);

  Future<List<BannerItem>> getActiveBanners() async {
    return await _repository.getActiveBanners();
  }

  Future<void> trackBannerClick(int bannerId) async {
    return await _repository.trackBannerClick(bannerId);
  }
}
