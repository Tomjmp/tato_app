import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/features/insights/domain/entities/stock_insight.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';

/// Computes the insight snapshot TÁTO surfaces on the Dashboard and
/// Insights screen: stock alerts, sales velocity and capital tied up
/// in inventory, derived purely from products + movement history.
class CalculateInsightsUseCase {
  const CalculateInsightsUseCase();

  static const _lookbackDays = 14;

  StockInsight call({
    required List<Product> products,
    required List<InventoryMovement> movements,
  }) {
    if (products.isEmpty) return StockInsight.empty();

    final now = DateTime.now();
    final windowStart = now.subtract(const Duration(days: _lookbackDays));

    final lowStock =
        products.where((p) => p.status == ProductStatus.lowStock).toList();
    final outOfStock =
        products.where((p) => p.status == ProductStatus.outOfStock).toList();
    final totalValue =
        products.fold<double>(0, (sum, p) => sum + p.totalValue);

    final velocities = <ProductVelocity>[];
    for (final product in products) {
      final unitsSold = movements
          .where((m) =>
              m.productId == product.localId &&
              m.isExit &&
              m.date.isAfter(windowStart))
          .fold<double>(0, (sum, m) => sum + m.quantity);

      final unitsPerDay = unitsSold / _lookbackDays;
      final daysRemaining =
          unitsPerDay > 0 ? (product.currentStock / unitsPerDay).ceil() : null;

      velocities.add(ProductVelocity(
        product: product,
        unitsPerDay: unitsPerDay,
        estimatedDaysRemaining: daysRemaining,
      ));
    }

    final moving = velocities.where((v) => v.unitsPerDay > 0).toList()
      ..sort((a, b) => b.unitsPerDay.compareTo(a.unitsPerDay));

    final slowMoving = velocities
        .where((v) => v.unitsPerDay == 0 && v.product.currentStock > 0)
        .toList()
      ..sort(
          (a, b) => b.product.currentStock.compareTo(a.product.currentStock));

    // Only products that still have stock are "about to run out" — items
    // already at zero belong to outOfStockProducts, not this list.
    final withDepletion = velocities
        .where((v) =>
            v.estimatedDaysRemaining != null && v.product.currentStock > 0)
        .toList()
      ..sort((a, b) =>
          a.estimatedDaysRemaining!.compareTo(b.estimatedDaysRemaining!));

    return StockInsight(
      lowStockProducts: lowStock,
      outOfStockProducts: outOfStock,
      fastMovingProducts: moving.take(3).toList(),
      slowMovingProducts: slowMoving.take(3).toList(),
      depletingSoonProducts: withDepletion.take(5).toList(),
      totalInventoryValue: totalValue,
      totalProducts: products.length,
      healthyProducts:
          products.where((p) => p.status == ProductStatus.inStock).length,
      mostUrgentDepletion:
          withDepletion.isNotEmpty ? withDepletion.first : null,
      calculatedAt: now,
    );
  }
}
