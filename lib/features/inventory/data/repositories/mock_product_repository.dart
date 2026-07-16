import 'dart:async';
import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/features/inventory/domain/repositories/product_repository.dart';
import 'package:tato_app/core/services/mock_data.dart';

class MockProductRepository implements ProductRepository {
  final List<Product> _products = List.from(MockData.products);
  final _controller = StreamController<List<Product>>.broadcast();

  @override
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_products);
  }

  @override
  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    } else {
      _products.insert(0, product);
    }
    _controller.add(List.unmodifiable(_products));
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _products.removeWhere((p) => p.id == id);
    _controller.add(List.unmodifiable(_products));
  }

  @override
  Stream<List<Product>> watchProducts() {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
