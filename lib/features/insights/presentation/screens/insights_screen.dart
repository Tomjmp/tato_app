import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/features/insights/domain/entities/stock_insight.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';
import 'package:tato_app/shared/widgets/empty_state.dart';
import 'package:tato_app/shared/widgets/error_state.dart';
import 'package:tato_app/shared/widgets/insight_card.dart';
import 'package:tato_app/shared/widgets/product_avatar.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  late Future<List<Object>> _dataFuture;

  @override
  void initState() {
    super.initState();
    // Cached once instead of rebuilt inside build() for the same reason
    // as Hoy/Perfil: avoids re-fetching (and flashing to loading state)
    // on every rebuild triggered by unrelated provider changes.
    final productRepo = ref.read(productRepositoryProvider);
    final movementRepo = ref.read(movementRepositoryProvider);
    _dataFuture = Future.wait([
      productRepo.getProducts(),
      movementRepo.getMovements(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final calculateInsights = ref.watch(calculateInsightsUseCaseProvider);

    return Scaffold(
      backgroundColor: TatoColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Object>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const ErrorState();
            }
            final products = (snapshot.data?[0] as List<Product>?) ?? [];
            final movements =
                (snapshot.data?[1] as List<InventoryMovement>?) ?? [];

            if (products.isEmpty) {
              return Column(
                children: [
                  _TopBar(onMenu: () => context.go('/profile')),
                  const Expanded(
                    child: EmptyState(
                      icon: Icons.insights_outlined,
                      title: 'Aún no hay datos suficientes',
                      subtitle: 'Agrega productos para que TÁTO empiece a generar insights.',
                    ),
                  ),
                ],
              );
            }

            final insight = calculateInsights(products: products, movements: movements);
            final weeklySales = _weeklySales(movements);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _TopBar(onMenu: () => context.go('/profile'))),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TatoSpacing.containerPadding,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RESUMEN GENERAL',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(letterSpacing: 1),
                        ),
                        Text('Insights', style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: TatoSpacing.lg),
                        _CapitalHeroCard(insight: insight),
                        const SizedBox(height: TatoSpacing.md),
                        _WeeklySalesCard(dailyUnits: weeklySales),
                        const SizedBox(height: TatoSpacing.xl),
                        Text('Oportunidades', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: TatoSpacing.sm),
                        for (final v in insight.fastMovingProducts)
                          Padding(
                            padding: const EdgeInsets.only(bottom: TatoSpacing.sm),
                            child: _OpportunityCard(
                              tag: 'MÁS VENDIDO',
                              tagColor: TatoColors.success,
                              icon: Icons.bolt_outlined,
                              velocity: v,
                              metric: '${v.unitsPerDay.toStringAsFixed(1)} uds./día',
                              onTap: () => context.push('/inventory/${v.product.localId}'),
                            ),
                          ),
                        for (final v in insight.slowMovingProducts)
                          Padding(
                            padding: const EdgeInsets.only(bottom: TatoSpacing.sm),
                            child: _OpportunityCard(
                              tag: 'SIN MOVIMIENTO',
                              tagColor: TatoColors.onSurfaceVariant,
                              icon: Icons.hourglass_disabled_outlined,
                              velocity: v,
                              metric: 'Sin ventas en 14 días',
                              onTap: () => context.push('/inventory/${v.product.localId}'),
                            ),
                          ),
                        if (insight.fastMovingProducts.isEmpty && insight.slowMovingProducts.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(TatoSpacing.md),
                            decoration: BoxDecoration(
                              color: TatoColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                            ),
                            child: const Text(
                              'Aún no hay suficiente historial de ventas para detectar tendencias.',
                              style: TextStyle(color: TatoColors.onSurfaceVariant, fontSize: 13),
                            ),
                          ),
                        const SizedBox(height: TatoSpacing.xl),
                        InsightCard(
                          title: 'Productos agotados',
                          subtitle: insight.outOfStockProducts.isEmpty
                              ? '¡Todo en orden! No hay productos agotados.'
                              : '${insight.outOfStockProducts.length} producto(s) sin stock.',
                          value: '${insight.outOfStockProducts.length}',
                          icon: Icons.remove_shopping_cart_outlined,
                          color: insight.outOfStockProducts.isEmpty
                              ? TatoColors.success
                              : TatoColors.error,
                        ),
                        const SizedBox(height: TatoSpacing.sm),
                        InsightCard(
                          title: 'Bajo nivel de stock',
                          subtitle: insight.lowStockProducts.isEmpty
                              ? 'Todos los productos tienen stock suficiente.'
                              : '${insight.lowStockProducts.length} producto(s) cerca del límite.',
                          value: '${insight.lowStockProducts.length}',
                          icon: Icons.trending_down_outlined,
                          color: insight.lowStockProducts.isEmpty
                              ? TatoColors.success
                              : TatoColors.warning,
                        ),
                        const SizedBox(height: TatoSpacing.xl),
                        _Section(
                          title: 'Productos por agotarse',
                          icon: Icons.hourglass_bottom_outlined,
                          color: TatoColors.warning,
                          empty: insight.depletingSoonProducts.isEmpty,
                          emptyLabel:
                              'Ningún producto muestra riesgo de agotarse pronto.',
                          children: insight.depletingSoonProducts
                              .map((v) => _VelocityTile(
                                    velocity: v,
                                    subtitle: v.depletionMessage,
                                    color: TatoColors.warning,
                                    onTap: () => context
                                        .push('/inventory/${v.product.localId}'),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: TatoSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Units sold per weekday (Mon..Sun) for the current calendar week.
  List<double> _weeklySales(List<InventoryMovement> movements) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final totals = List<double>.filled(7, 0);
    for (final m in movements) {
      if (!m.isExit) continue;
      final diff = m.date.difference(startOfWeek).inDays;
      if (diff >= 0 && diff < 7) totals[diff] += m.quantity;
    }
    return totals;
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onMenu;

  const _TopBar({required this.onMenu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TatoSpacing.containerPadding,
        vertical: TatoSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.menu), onPressed: onMenu),
          Expanded(
            child: Text('TÁTO',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          ),
          GestureDetector(
            onTap: onMenu,
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: TatoColors.primaryContainer,
              child: Icon(Icons.person_outline, size: 18, color: TatoColors.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapitalHeroCard extends StatelessWidget {
  final StockInsight insight;

  const _CapitalHeroCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TatoSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TatoColors.primary, Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
        boxShadow: TatoShadows.level2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dinero en inventario',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'RD\$ ${insight.totalInventoryValue.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                insight.hasAlerts ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                insight.hasAlerts
                    ? '${insight.alertCount} alertas activas'
                    : 'Sin alertas activas',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklySalesCard extends StatelessWidget {
  final List<double> dailyUnits;

  const _WeeklySalesCard({required this.dailyUnits});

  static const _dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final maxValue = dailyUnits.fold<double>(0, (m, v) => v > m ? v : m);
    final todayIndex = DateTime.now().weekday - 1;

    return Container(
      width: double.infinity,
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
          Text('Ventas Semanales', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TatoSpacing.md),
          SizedBox(
            height: 96,
            child: maxValue == 0
                ? Center(
                    child: Text('Sin ventas esta semana',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: TatoColors.onSurfaceVariant)),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final ratio = maxValue == 0 ? 0.0 : dailyUnits[i] / maxValue;
                      final isToday = i == todayIndex;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: (72 * ratio).clamp(3, 72).toDouble(),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? TatoColors.primary
                                      : TatoColors.primary.withOpacity(0.35),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _dayLabels[i],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                                  color: isToday ? TatoColors.primary : TatoColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final IconData icon;
  final ProductVelocity velocity;
  final String metric;
  final VoidCallback onTap;

  const _OpportunityCard({
    required this.tag,
    required this.tagColor,
    required this.icon,
    required this.velocity,
    required this.metric,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
              ),
              child: Icon(icon, color: tagColor, size: 20),
            ),
            const SizedBox(width: TatoSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tag,
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700, color: tagColor, letterSpacing: 0.4)),
                  Text(velocity.product.name,
                      style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                  Text(metric,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: TatoColors.onSurfaceVariant)),
                ],
              ),
            ),
            ProductAvatar(
              imageUrl: velocity.product.imageUrl,
              categoryName: velocity.product.categoryName,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool empty;
  final String emptyLabel;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.empty,
    required this.emptyLabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: TatoSpacing.sm),
        if (empty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TatoSpacing.md),
            decoration: BoxDecoration(
              color: TatoColors.surfaceVariant,
              borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
            ),
            child: Text(
              emptyLabel,
              style: const TextStyle(color: TatoColors.onSurfaceVariant, fontSize: 13),
            ),
          )
        else
          ...children.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: TatoSpacing.sm),
                child: c,
              )),
      ],
    );
  }
}

class _VelocityTile extends StatelessWidget {
  final ProductVelocity velocity;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _VelocityTile({
    required this.velocity,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            ProductAvatar(
              imageUrl: velocity.product.imageUrl,
              categoryName: velocity.product.categoryName,
              size: 42,
            ),
            const SizedBox(width: TatoSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(velocity.product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: TatoColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
