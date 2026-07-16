import 'package:tato_app/features/category/domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasource/mock_category_datasource.dart';

class MockCategoryRepository implements CategoryRepository {
  final MockCategoryDataSource dataSource;

  const MockCategoryRepository(this.dataSource);

  @override
  Future<List<Category>> getCategories(String businessId) {
    return dataSource.getCategories(businessId);
  }

  @override
  Future<Category> createCategory({
    required String id,
    required String businessId,
    required String name,
    bool isDefault = false,
  }) {
    return dataSource.createCategory(
      id: id,
      businessId: businessId,
      name: name,
      isDefault: isDefault,
    );
  }

  @override
  Future<void> updateCategory(Category category) {
    return dataSource.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) {
    return dataSource.deleteCategory(id);
  }
}
