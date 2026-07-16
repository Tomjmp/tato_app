import '../entities/category.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> getCategories(String businessId);

  Future<Category> createCategory({
    required String id,
    required String businessId,
    required String name,
    bool isDefault = false,
  });

  Future<void> updateCategory(Category category);

  Future<void> deleteCategory(String id);
}
