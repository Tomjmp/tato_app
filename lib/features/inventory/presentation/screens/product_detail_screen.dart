import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';
import 'package:tato_app/shared/widgets/custom_button.dart';
import 'package:tato_app/shared/widgets/empty_state.dart';
import 'package:tato_app/shared/widgets/error_state.dart';
import 'package:tato_app/shared/widgets/movement_tile.dart';
import 'package:tato_app/shared/widgets/product_avatar.dart';
import 'package:tato_app/shared/widgets/stock_badge.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late Future<Product?> _productFuture;
  late Future<List<InventoryMovement>> _movementsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _productFuture =
        ref.read(productRepositoryProvider).getProductById(widget.productId);
    _movementsFuture = ref
        .read(movementRepositoryProvider)
        .getMovements(productId: widget.productId);
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_productFuture, _movementsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatoColors.background,
      body: FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(backgroundColor: TatoColors.background, elevation: 0),
              body: const ErrorState(),
            );
          }
          final product = snapshot.data;
          if (product == null) {
            return Scaffold(
              appBar: AppBar(backgroundColor: TatoColors.background, elevation: 0),
              body: const Center(child: Text('Producto no encontrado.')),
            );
          }

          final statusColor = StockBadge.colorFor(product.status);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: TatoColors.background,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(product.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        await context.push('/inventory/${product.id}/edit');
                        if (mounted) _refresh();
                      },
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(TatoSpacing.containerPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Center(
                        child: ProductAvatar(
                          imageUrl: product.imageUrl,
                          categoryName: product.categoryName,
                          size: 88,
                          radius: TatoSizes.radiusXl,
                        ),
                      ),
                      const SizedBox(height: TatoSpacing.md),
                      // Stock hero card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(TatoSpacing.lg),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${product.currentStock.toInt()}',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            Text(
                              'unidades en stock',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: statusColor),
                            ),
                            const SizedBox(height: TatoSpacing.sm),
                            StockBadge(status: product.status),
                          ],
                        ),
                      ),
                      const SizedBox(height: TatoSpacing.lg),
                      _DetailSection(
                        title: 'Detalles del producto',
                        rows: [
                          _DetailRow(label: 'SKU', value: product.sku ?? '—'),
                          _DetailRow(
                              label: 'Categoría',
                              value: product.categoryName ?? 'Sin categoría'),
                          _DetailRow(
                              label: 'Precio de venta',
                              value: 'RD\$ ${product.price.toStringAsFixed(2)}'),
                          _DetailRow(
                              label: 'Costo',
                              value: 'RD\$ ${product.cost.toStringAsFixed(2)}'),
                          _DetailRow(
                              label: 'Alerta de stock mínimo',
                              value: '${product.minStockAlert.toInt()} uds.'),
                          _DetailRow(
                              label: 'Valor en inventario',
                              value:
                                  'RD\$ ${product.totalValue.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: TatoSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: 'Registrar salida',
                              icon: Icons.remove_circle_outline,
                              variant: CustomButtonVariant.danger,
                              onPressed: () async {
                                await context.push(
                                    '/new-movement?productId=${product.id}');
                                if (mounted) _refresh();
                              },
                            ),
                          ),
                          const SizedBox(width: TatoSpacing.sm),
                          Expanded(
                            child: CustomButton(
                              label: 'Registrar entrada',
                              icon: Icons.add_circle_outline,
                              variant: CustomButtonVariant.secondary,
                              onPressed: () async {
                                await context.push(
                                    '/new-movement?productId=${product.id}');
                                if (mounted) _refresh();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TatoSpacing.lg),
                      Text('Historial de movimientos',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: TatoSpacing.sm),
                      FutureBuilder<List<InventoryMovement>>(
                        future: _movementsFuture,
                        builder: (context, moveSnapshot) {
                          if (moveSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: TatoSpacing.lg),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (moveSnapshot.hasError) {
                            return const ErrorState(
                              message: 'No se pudo cargar el historial de movimientos.',
                            );
                          }
                          final movements = moveSnapshot.data ?? [];
                          if (movements.isEmpty) {
                            return const EmptyState(
                              icon: Icons.history_outlined,
                              title: 'Sin movimientos aún',
                              subtitle:
                                  'Las entradas y salidas de este producto aparecerán aquí.',
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: TatoColors.surface,
                              borderRadius:
                                  BorderRadius.circular(TatoSizes.radiusXl),
                              border: Border.all(color: TatoColors.border),
                              boxShadow: TatoShadows.level1,
                            ),
                            child: Column(
                              children: movements
                                  .asMap()
                                  .entries
                                  .map((e) => Column(
                                        children: [
                                          MovementTile(movement: e.value),
                                          if (e.key < movements.length - 1)
                                            const Divider(
                                                height: 1, indent: 16, endIndent: 16),
                                        ],
                                      ))
                                  .toList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: TatoSpacing.xxl),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;

  const _DetailSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: TatoSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: TatoColors.surface,
            borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
            border: Border.all(color: TatoColors.border),
            boxShadow: TatoShadows.level1,
          ),
          child: Column(
            children: rows
                .asMap()
                .entries
                .map(
                  (e) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TatoSpacing.md,
                          vertical: TatoSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.value.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: TatoColors.onSurfaceVariant),
                            ),
                            Text(
                              e.value.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: TatoColors.primary,
                                      fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (e.key < rows.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DetailRow {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
}
