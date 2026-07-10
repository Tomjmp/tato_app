import 'package:flutter/material.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/features/inventory/domain/entities/product.dart';

/// Small pill that communicates a product's stock status at a glance.
/// Centralizes the status → color/label/icon mapping so screens never
/// re-derive it independently.
class StockBadge extends StatelessWidget {
  final ProductStatus status;
  final bool dense;

  const StockBadge({super.key, required this.status, this.dense = false});

  static Color colorFor(ProductStatus status) {
    switch (status) {
      case ProductStatus.inStock:
        return TatoColors.success;
      case ProductStatus.lowStock:
        return TatoColors.warning;
      case ProductStatus.outOfStock:
        return TatoColors.error;
    }
  }

  static String labelFor(ProductStatus status) {
    switch (status) {
      case ProductStatus.inStock:
        return 'Disponible';
      case ProductStatus.lowStock:
        return 'Bajo stock';
      case ProductStatus.outOfStock:
        return 'Agotado';
    }
  }

  static IconData iconFor(ProductStatus status) {
    switch (status) {
      case ProductStatus.inStock:
        return Icons.check_circle_outline;
      case ProductStatus.lowStock:
        return Icons.warning_amber_outlined;
      case ProductStatus.outOfStock:
        return Icons.remove_shopping_cart_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(status), size: dense ? 11 : 13, color: color),
          const SizedBox(width: 4),
          Text(
            labelFor(status),
            style: TextStyle(
              color: color,
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
