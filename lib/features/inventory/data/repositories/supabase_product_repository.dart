import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/core/errors/supabase_error_mapper.dart';
import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/features/inventory/domain/repositories/product_repository.dart';

/// Talks to the `products` table (0004_products.sql). `deleteProduct` never
/// issues a physical DELETE — it sets `deleted_at`, and every read filters
/// `deleted_at is null` so soft-deleted rows disappear from the app without
/// losing the history that `inventory_movements` still references.
class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient _client;

  SupabaseProductRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  static const _selectWithCategory = '*, categories(name)';

  @override
  Future<List<Product>> getProducts() async {
    try {
      final rows = await _client
          .from('products')
          .select(_selectWithCategory)
          .filter('deleted_at', 'is', null)
          .order('created_at', ascending: false);
      return (rows as List).map((r) => _mapProduct(r as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final row = await _client
          .from('products')
          .select(_selectWithCategory)
          .eq('id', id)
          .filter('deleted_at', 'is', null)
          .maybeSingle();
      if (row == null) return null;
      return _mapProduct(row);
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> saveProduct(Product product) async {
    try {
      await _client.from('products').upsert({
        'id': product.id,
        'business_id': product.businessId,
        'category_id': product.categoryId,
        'name': product.name,
        'description': product.description,
        'sku': product.sku,
        'image_url': product.imageUrl,
        'price': product.price,
        'cost': product.cost,
        'current_stock': product.currentStock,
        'min_stock_alert': product.minStockAlert,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _client
          .from('products')
          .update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', id);
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    // Realtime .stream() only mirrors the raw table (no relational
    // embedding), so categoryName isn't available on this path — acceptable
    // since nothing in the app currently consumes watchProducts().
    return _client
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows
            .where((r) => r['deleted_at'] == null)
            .map((r) => _mapProductRow(r, categoryName: null))
            .toList());
  }

  Product _mapProduct(Map<String, dynamic> row) {
    final categoryName = (row['categories'] as Map<String, dynamic>?)?['name'] as String?;
    return _mapProductRow(row, categoryName: categoryName);
  }

  Product _mapProductRow(Map<String, dynamic> row, {required String? categoryName}) {
    return Product(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      sku: row['sku'] as String?,
      categoryId: row['category_id'] as String?,
      categoryName: categoryName,
      imageUrl: row['image_url'] as String?,
      price: (row['price'] as num).toDouble(),
      cost: (row['cost'] as num).toDouble(),
      currentStock: (row['current_stock'] as num).toDouble(),
      minStockAlert: (row['min_stock_alert'] as num).toDouble(),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      synced: true,
    );
  }
}
