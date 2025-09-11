import '../../../data/models/photographer_category.dart';
import '../../../data/models/repositories/photographer_category_repository.dart';

class PhotographerCategoryApiService {
  final PhotographerCategoryRepository _repository;

  PhotographerCategoryApiService(this._repository);

  Future<List<PhotographerCategory>> getCategories() async {
    return await _repository.getCategories();
  }
}
