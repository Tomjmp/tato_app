import 'package:flutter/material.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/shared/widgets/product_avatar.dart';
import 'package:tato_app/shared/widgets/stock_badge.dart';

/// Standard inventory list row: photo/icon, name, category, stock and
/// status badge. Used by Inventory and can be reused anywhere a product
/// needs to be listed (e.g. movement pickers, search results).
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final showMenu = onEdit != null || onDelete != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TatoSpacing.md),
        decoration: BoxDecoration(
          color: TatoColors.surface,
          borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
          border: Border.all(color: TatoColors.border),
          boxShadow: TatoShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductAvatar(
                  imageUrl: product.imageUrl,
                  categoryName: product.categoryName,
                  size: 64,
                ),
                const SizedBox(width: TatoSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.categoryName ?? 'Sin categoría',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                if (showMenu)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: TatoColors.onSurfaceVariant),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ]),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline, size: 18, color: TatoColors.error),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: TatoColors.error)),
                          ]),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: TatoSpacing.sm),
            Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 16, color: StockBadge.colorFor(product.status)),
                const SizedBox(width: 4),
                Text(
                  '${product.currentStock.toInt()} unidades',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: StockBadge.colorFor(product.status),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                StockBadge(status: product.status, dense: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
