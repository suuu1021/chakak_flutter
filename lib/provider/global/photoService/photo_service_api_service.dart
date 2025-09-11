import '../../../data/models/photo_service.dart';
import '../../../data/models/repositories/photo_service_repository.dart';

class PhotoServiceApiService {
  final PhotoServiceRepository _repository;

  PhotoServiceApiService(this._repository);

  Future<List<PhotoService>> getServices() async {
    return await _repository.getServices();
  }

  Future<void> updateLikeStatus(int serviceId, bool isLiked) async {
    return await _repository.updateLikeStatus(serviceId, isLiked);
  }
}
