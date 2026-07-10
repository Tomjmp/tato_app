import 'package:tato_app/features/inventory/domain/entities/product.dart';

/// Resultado del motor de inteligencia de inventario
class StockInsight {
  final List<Product> lowStockProducts;
  final List<Product> outOfStockProducts;
  final List<ProductVelocity> fastMovingProducts;
  final List<ProductVelocity> slowMovingProducts;
  final List<ProductVelocity> depletingSoonProducts;
  final double totalInventoryValue;
  final int totalProducts;
  final int healthyProducts;
  final ProductVelocity? mostUrgentDepletion;
  final DateTime calculatedAt;

  const StockInsight({
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.fastMovingProducts,
    required this.slowMovingProducts,
    this.depletingSoonProducts = const [],
    required this.totalInventoryValue,
    required this.totalProducts,
    required this.healthyProducts,
    this.mostUrgentDepletion,
    required this.calculatedAt,
  });

  bool get hasAlerts =>
      lowStockProducts.isNotEmpty || outOfStockProducts.isNotEmpty;

  int get alertCount =>
      lowStockProducts.length + outOfStockProducts.length;

  static StockInsight empty() {
    return StockInsight(
      lowStockProducts: const [],
      outOfStockProducts: const [],
      fastMovingProducts: const [],
      slowMovingProducts: const [],
      totalInventoryValue: 0,
      totalProducts: 0,
      healthyProducts: 0,
      calculatedAt: DateTime.now(),
    );
  }
}

class ProductVelocity {
  final Product product;
  final double unitsPerDay;
  final int? estimatedDaysRemaining;

  const ProductVelocity({
    required this.product,
    required this.unitsPerDay,
    this.estimatedDaysRemaining,
  });

  String get depletionMessage {
    if (estimatedDaysRemaining == null) return 'Sin suficiente historial';
    if (estimatedDaysRemaining! <= 0) return 'Agotado';
    if (estimatedDaysRemaining! == 1) return 'Se agota mañana';
    return 'Se agota en ~$estimatedDaysRemaining días';
  }
}
