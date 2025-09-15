import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/repositories/photo_service_repository.dart';

class PhotoServiceApiService {
  final PhotoServiceRepository _repository;

  PhotoServiceApiService(this._repository);

  Future<List<PhotoService>> getServices() async {
    return await _repository.getServices();
  }

  // 포토그래퍼별 서비스 조회 메서드 추가
  Future<List<PhotoService>> getServicesByPhotographer(
      int photographerId) async {
    return await _repository.getServicesByPhotographer(photographerId);
  }

  Future<void> updateLikeStatus(int serviceId, bool isLiked) async {
    return await _repository.updateLikeStatus(serviceId, isLiked);
  }
}
