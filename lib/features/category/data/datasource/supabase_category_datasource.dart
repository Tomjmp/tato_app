import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/core/errors/supabase_error_mapper.dart';
import 'package:tato_app/features/category/domain/entities/category.dart';

/// Talks to the `categories` table, always scoped by `business_id` and
/// subject to RLS (0003_categories.sql).
///
/// `createCategory` treats a unique_violation on (business_id, name) as a
/// success instead of an error: `create_business_with_default_categories`
/// (0006_functions.sql) already seeds the 9 default categories atomically
/// when a business is created, but `SetupBusinessScreen` — unchanged, per
/// scope — still calls `SeedDefaultCategoriesUseCase` right after. Rather
/// than touch that screen, this makes the redundant seed call a no-op that
/// resolves to the row the RPC already created.
class SupabaseCategoryDataSource {
  final SupabaseClient _client;

  SupabaseCategoryDataSource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<Category>> getCategories(String businessId) async {
    try {
      final rows = await _client
          .from('categories')
          .select()
          .eq('business_id', businessId)
          .order('created_at');
      return (rows as List).map((r) => _mapCategory(r as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  Future<Category> createCategory({
    required String id,
    required String businessId,
    required String name,
    bool isDefault = false,
  }) async {
    try {
      final row = await _client
          .from('categories')
          .insert({
            'id': id,
            'business_id': businessId,
            'name': name,
            'is_default': isDefault,
          })
          .select()
          .single();
      return _mapCategory(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        final existing = await _client
            .from('categories')
            .select()
            .eq('business_id', businessId)
            .eq('name', name)
            .single();
        return _mapCategory(existing);
      }
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _client.from('categories').update({
        'name': category.name,
        'is_default': category.isDefault,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', category.id);
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _client.from('categories').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  Category _mapCategory(Map<String, dynamic> row) {
    return Category(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      name: row['name'] as String,
      isDefault: row['is_default'] as bool,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
