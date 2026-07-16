import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<List<Category>> call(String businessId) {
    return repository.getCategories(businessId);
  }
}
