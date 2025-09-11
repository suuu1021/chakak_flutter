import '../../../data/models/photo_service_category.dart';
import '../../../data/models/repositories/photo_service_category_repository.dart';

class PhotoServiceCategoryApiService {
  final PhotoServiceCategoryRepository _repository;

  PhotoServiceCategoryApiService(this._repository);

  Future<List<PhotoServiceCategory>> getCategories() async {
    return await _repository.getCategories();
  }
}
