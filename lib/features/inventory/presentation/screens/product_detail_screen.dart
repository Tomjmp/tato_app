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

  /// Días estimados hasta agotarse según las salidas de los últimos 14 días.
  /// Misma fórmula del motor de insights: stock / promedio diario de salida.
  int? _daysToDeplete(Product product, List<InventoryMovement> movements) {
    if (product.currentStock <= 0) return 0;
    final since = DateTime.now().subtract(const Duration(days: 14));
    final exits = movements
        .where((m) => m.isExit && m.date.isAfter(since))
        .fold<double>(0, (sum, m) => sum + m.quantity);
    if (exits <= 0) return null;
    return (product.currentStock / (exits / 14)).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(backgroundColor: Theme.of(context).scaffoldBackgroundColor, elevation: 0),
              body: const ErrorState(),
            );
          }
          final product = snapshot.data;
          if (product == null) {
            return Scaffold(
              appBar: AppBar(backgroundColor: Theme.of(context).scaffoldBackgroundColor, elevation: 0),
              body: const Center(child: Text('Producto no encontrado.')),
            );
          }

          final categoryColor = TatoCategories.colorFor(product.categoryName);
          final margin = product.price > 0
              ? ((product.price - product.cost) / product.price * 100)
              : null;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  ),
                  title: const Text('Producto'),
                  centerTitle: true,
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
                          size: 80,
                          radius: TatoSizes.radiusXl,
                          heroTag: 'product-avatar-${product.id}',
                        ),
                      ),
                      const SizedBox(height: TatoSpacing.sm),
                      Text(
                        product.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: TatoSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (product.categoryName != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(
                                    TatoSizes.radiusPill),
                              ),
                              child: Text(
                                product.categoryName!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          StockBadge(status: product.status),
                        ],
                      ),
                      const SizedBox(height: TatoSpacing.md),
                      FutureBuilder<List<InventoryMovement>>(
                        future: _movementsFuture,
                        builder: (context, moveSnapshot) {
                          final movements = moveSnapshot.data ?? [];
                          final days = _daysToDeplete(product, movements);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetricTile(
                                      value:
                                          '${product.currentStock.toInt()}',
                                      label: 'Stock',
                                    ),
                                  ),
                                  const SizedBox(width: TatoSpacing.xs),
                                  Expanded(
                                    child: _MetricTile(
                                      value:
                                          '${product.minStockAlert.toInt()}',
                                      label: 'Mínimo',
                                    ),
                                  ),
                                  const SizedBox(width: TatoSpacing.xs),
                                  Expanded(
                                    child: _MetricTile(
                                      value: days == null
                                          ? '—'
                                          : days <= 0
                                              ? 'Agotado'
                                              : '~$days días',
                                      label: 'Se agota',
                                      background: days != null && days <= 7
                                          ? TatoColors.coralTint
                                          : null,
                                      foreground: days != null && days <= 7
                                          ? TatoColors.onCoralTint
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: TatoSpacing.sm),
                              _PriceCard(product: product, margin: margin),
                              const SizedBox(height: TatoSpacing.lg),
                              _DetailSection(
                                title: 'Detalles del producto',
                                rows: [
                                  _DetailRow(
                                      label: 'SKU', value: product.sku ?? '—'),
                                  _DetailRow(
                                      label: 'Categoría',
                                      value: product.categoryName ??
                                          'Sin categoría'),
                                  _DetailRow(
                                      label: 'Alerta de stock mínimo',
                                      value:
                                          '${product.minStockAlert.toInt()} uds.'),
                                  _DetailRow(
                                      label: 'Valor en inventario',
                                      value:
                                          'RD\$ ${product.totalValue.toStringAsFixed(2)}'),
                                ],
                              ),
                              const SizedBox(height: TatoSpacing.lg),
                              Text('Historial de movimientos',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: TatoSpacing.sm),
                              if (moveSnapshot.connectionState ==
                                  ConnectionState.waiting)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: TatoSpacing.lg),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              else if (moveSnapshot.hasError)
                                const ErrorState(
                                  message:
                                      'No se pudo cargar el historial de movimientos.',
                                )
                              else if (movements.isEmpty)
                                const EmptyState(
                                  icon: Icons.history_outlined,
                                  title: 'Sin movimientos aún',
                                  subtitle:
                                      'Las entradas y salidas de este producto aparecerán aquí.',
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(
                                        TatoSizes.radiusLg),
                                    border:
                                        Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                  ),
                                  child: Column(
                                    children: movements
                                        .asMap()
                                        .entries
                                        .map((e) => Column(
                                              children: [
                                                MovementTile(
                                                    movement: e.value),
                                                if (e.key <
                                                    movements.length - 1)
                                                  const Divider(
                                                      height: 1,
                                                      indent: 16,
                                                      endIndent: 16),
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                ),
                              const SizedBox(height: TatoSpacing.lg),
                              CustomButton(
                                label: 'Registrar movimiento',
                                icon: Icons.swap_vert,
                                onPressed: () async {
                                  await context.push(
                                      '/new-movement?productId=${product.id}');
                                  if (mounted) _refresh();
                                },
                              ),
                              const SizedBox(height: TatoSpacing.xxl),
                            ],
                          );
                        },
                      ),
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

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? background;
  final Color? foreground;

  const _MetricTile({
    required this.value,
    required this.label,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Theme.of(context).colorScheme.surface;
    final fg = foreground ?? Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TatoSpacing.xs,
        vertical: TatoSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
        border: background == null
            ? Border.all(color: Theme.of(context).colorScheme.outlineVariant)
            : null,
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 18, color: fg),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foreground ?? TatoColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final Product product;
  final double? margin;

  const _PriceCard({required this.product, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: TatoSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _priceColumn(context, 'Costo',
              'RD\$${product.cost.toStringAsFixed(0)}', Theme.of(context).colorScheme.onSurface),
          _separator(context),
          _priceColumn(context, 'Venta',
              'RD\$${product.price.toStringAsFixed(0)}', Theme.of(context).colorScheme.onSurface),
          _separator(context),
          _priceColumn(
              context,
              'Margen',
              margin == null ? '—' : '${margin!.toStringAsFixed(0)}%',
              const Color(0xFF0F766E)),
        ],
      ),
    );
  }

  Widget _separator(BuildContext context) =>
      Container(width: 1, height: 28, color: Theme.of(context).colorScheme.outlineVariant);

  Widget _priceColumn(
      BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: TatoColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                                      color: Theme.of(context).colorScheme.onSurface,
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
