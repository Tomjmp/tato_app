import 'package:tato_app/features/category/domain/entities/category.dart';

/// Stands in for a real remote call (e.g. Supabase). Keeps an in-memory
/// map keyed by category id, filtered by businessId on read — swapping to
/// `SupabaseCategoryDataSource` later is a one-file change.
class MockCategoryDataSource {
  final Map<String, Category> _categories = {};

  Future<List<Category>> getCategories(String businessId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _categories.values.where((c) => c.businessId == businessId).toList();
  }

  Future<Category> createCategory({
    required String id,
    required String businessId,
    required String name,
    bool isDefault = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final category = Category(
      id: id,
      businessId: businessId,
      name: name,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );
    _categories[id] = category;
    return category;
  }

  Future<void> updateCategory(Category category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _categories[category.id] = category;
  }

  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _categories.remove(id);
  }
}
