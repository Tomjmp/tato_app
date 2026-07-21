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
import 'package:tato_app/shared/widgets/fade_in.dart';
import 'package:tato_app/shared/widgets/movement_tile.dart';
import 'package:tato_app/shared/widgets/product_avatar.dart';
import 'package:tato_app/shared/widgets/stock_badge.dart';

class HoyScreen extends ConsumerStatefulWidget {
  const HoyScreen({super.key});

  @override
  ConsumerState<HoyScreen> createState() => _HoyScreenState();
}

class _HoyScreenState extends ConsumerState<HoyScreen> {
  late Future<List<Object>> _dataFuture;

  @override
  void initState() {
    super.initState();
    // Cached once instead of rebuilt inside build() — this screen watches
    // currentUserProvider, and re-fetching on every rebuild would flash
    // the whole dashboard back to its loading state unnecessarily.
    _loadData();
  }

  void _loadData() {
    final productRepo = ref.read(productRepositoryProvider);
    final movementRepo = ref.read(movementRepositoryProvider);
    _dataFuture = Future.wait([
      productRepo.getProducts(),
      movementRepo.getMovements(),
    ]);
  }

  String _todayLabel() {
    const weekdays = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]} ${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final calculateInsights = ref.watch(calculateInsightsUseCaseProvider);
    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(_loadData);
            await _dataFuture;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: TatoSpacing.containerPadding,
                vertical: TatoSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName.isEmpty ? 'Hola' : 'Hola, $firstName',
                            style:
                                Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            _todayLabel(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Ver alertas',
                      onPressed: () => context.go('/insights'),
                    ),
                    Semantics(
                      button: true,
                      label: 'Abrir perfil',
                      child: InkWell(
                        onTap: () => context.go('/profile'),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: CircleAvatar(
                            radius: 19,
                            backgroundColor: TatoColors.primaryContainer,
                            child: Text(
                              (user?.name?.isNotEmpty ?? false)
                                  ? user!.name![0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: TatoColors.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: TatoSpacing.containerPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<List<Object>>(
                  future: _dataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _LoadingState();
                    }
                    if (snapshot.hasError) {
                      return const ErrorState();
                    }
                    final products =
                        (snapshot.data?[0] as List<Product>?) ?? [];
                    final movements =
                        (snapshot.data?[1] as List<InventoryMovement>?) ?? [];
                    final insight = calculateInsights(
                      products: products,
                      movements: movements,
                    );
                    final attention = products
                        .where((p) => p.needsAttention)
                        .toList()
                      ..sort(
                          (a, b) => a.currentStock.compareTo(b.currentStock));
                    final recentMovements = [...movements]
                      ..sort((a, b) => b.date.compareTo(a.date));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeIn(child: _HeroCard(insight: insight)),
                        const SizedBox(height: TatoSpacing.sm),
                        FadeIn(
                          delay: const Duration(milliseconds: 90),
                          child: Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                value: '${insight.healthyProducts}',
                                label: 'Estables',
                                background: TatoColors.mintTint,
                                foreground: TatoColors.onMintTint,
                              ),
                            ),
                            const SizedBox(width: TatoSpacing.xs),
                            Expanded(
                              child: _MiniStat(
                                value: '${insight.lowStockProducts.length}',
                                label: 'Atención',
                                background: TatoColors.amberTint,
                                foreground: TatoColors.onAmberTint,
                              ),
                            ),
                            const SizedBox(width: TatoSpacing.xs),
                            Expanded(
                              child: _MiniStat(
                                value: '${insight.outOfStockProducts.length}',
                                label: 'En riesgo',
                                background: TatoColors.coralTint,
                                foreground: TatoColors.onCoralTint,
                              ),
                            ),
                          ],
                          ),
                        ),
                        if (attention.isNotEmpty) ...[
                          const SizedBox(height: TatoSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Necesitan atención',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                              TextButton(
                                onPressed: () => context.go('/inventory'),
                                child: const Text('Ver todo'),
                              ),
                            ],
                          ),
                          const SizedBox(height: TatoSpacing.unit),
                          ...attention.take(3).map(
                                (p) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: TatoSpacing.xs),
                                  child: _AttentionRow(
                                    product: p,
                                    onTap: () =>
                                        context.push('/inventory/${p.id}'),
                                  ),
                                ),
                              ),
                        ],
                        const SizedBox(height: TatoSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: Text('Movimientos recientes',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                            ),
                            TextButton(
                              onPressed: () => context.go('/insights'),
                              child: const Text('Ver todos'),
                            ),
                          ],
                        ),
                        if (recentMovements.isEmpty)
                          const EmptyState(
                            icon: Icons.history_outlined,
                            title: 'Sin movimientos aún',
                            subtitle: 'Tus entradas y salidas aparecerán aquí.',
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius:
                                  BorderRadius.circular(TatoSizes.radiusLg),
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: Column(
                              children: recentMovements
                                  .take(4)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((e) {
                                return Column(
                                  children: [
                                    MovementTile(
                                        movement: e.value,
                                        showProductName: true),
                                    if (e.key <
                                        recentMovements.take(4).length - 1)
                                      const Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        const SizedBox(height: TatoSpacing.xxl),
                      ],
                    );
                  },
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta héroe "TÁTO notó esto": siempre lo primero después del saludo.
/// Azul pleno cuando hay algo urgente que decir; tinte azul claro con
/// mensaje neutro cuando el inventario está estable.
class _HeroCard extends StatelessWidget {
  final StockInsight insight;

  const _HeroCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final urgent = insight.mostUrgentDepletion;
    final stable = urgent == null && !insight.hasAlerts;

    if (stable) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TatoSpacing.md),
        decoration: BoxDecoration(
          color: TatoColors.primaryContainer,
          borderRadius: BorderRadius.circular(TatoSizes.radiusHero),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome_outlined,
                    size: 15, color: TatoColors.onPrimaryContainer),
                SizedBox(width: 6),
                Text(
                  'TÁTO notó esto',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: TatoColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Tu inventario está estable. Sin alertas críticas por ahora.',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: TatoColors.onPrimaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    final message = urgent != null
        ? '${urgent.product.name} podría agotarse en '
            '${urgent.estimatedDaysRemaining == 1 ? '1 día' : '${urgent.estimatedDaysRemaining} días'} '
            'al ritmo actual.'
        : '${insight.alertCount} '
            '${insight.alertCount == 1 ? 'producto necesita' : 'productos necesitan'} '
            'tu atención hoy.';
    final onTap = urgent != null
        ? () => context.push('/inventory/${urgent.product.id}')
        : () => context.go('/inventory');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TatoSpacing.md),
        decoration: BoxDecoration(
          color: TatoColors.primary,
          borderRadius: BorderRadius.circular(TatoSizes.radiusHero),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome_outlined,
                    size: 15, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'TÁTO notó esto',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  urgent != null ? 'Ver producto' : 'Ver inventario',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward,
                    size: 13, color: Colors.white.withOpacity(0.85)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Semáforo del inventario: número grande + etiqueta, sobre tinte de estado.
class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color background;
  final Color foreground;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TatoSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // El número entra con crossfade cuando cambia tras un refresh.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              value,
              key: ValueKey(value),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: foreground),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _AttentionRow({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final stock = product.currentStock;
    final quantity = stock <= 0
        ? 'Sin unidades'
        : 'Quedan ${stock == stock.roundToDouble() ? stock.toInt() : stock}';
    final subtitle = product.categoryName == null
        ? quantity
        : '$quantity · ${product.categoryName}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TatoSpacing.sm,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            ProductAvatar(
              imageUrl: product.imageUrl,
              categoryName: product.categoryName,
              size: 40,
            ),
            const SizedBox(width: TatoSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: TatoColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            StockBadge(status: product.status, dense: true),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(TatoSpacing.xxl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
