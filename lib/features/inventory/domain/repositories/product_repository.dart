import 'package:tato_app/features/inventory/domain/entities/product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String localId);
  Future<void> saveProduct(Product product);
  Future<void> deleteProduct(String localId);
  Stream<List<Product>> watchProducts();
}
