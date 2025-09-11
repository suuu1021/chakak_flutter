import '../../../data/models/photographer.dart';
import '../../../data/models/repositories/photographer_repository.dart';

class PhotographerApiService {
  final PhotographerRepository _repository;

  PhotographerApiService(this._repository);

  Future<List<Photographer>> getPhotographers() async {
    return await _repository.getPhotographers();
  }

  Future<void> updateLikeStatus(int photographerId, bool isLiked) async {
    return await _repository.updateLikeStatus(photographerId, isLiked);
  }
}
