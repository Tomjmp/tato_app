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
import 'package:tato_app/shared/widgets/movement_tile.dart';

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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final calculateInsights = ref.watch(calculateInsightsUseCaseProvider);

    return Scaffold(
      backgroundColor: TatoColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: TatoSpacing.containerPadding,
                vertical: TatoSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
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
                    const SizedBox(width: TatoSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola ${user?.name ?? ''} 👋',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: TatoColors.onSurfaceVariant),
                          ),
                          Text('TÁTO', style: Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => context.go('/profile'),
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
                    final today = DateTime.now();
                    final movementsToday = movements
                        .where((m) =>
                            m.date.year == today.year &&
                            m.date.month == today.month &&
                            m.date.day == today.day)
                        .length;
                    final recentMovements = [...movements]
                      ..sort((a, b) => b.date.compareTo(a.date));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatusHeroCard(insight: insight),
                        const SizedBox(height: TatoSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                label: 'Productos',
                                value: '${insight.totalProducts}',
                              ),
                            ),
                            const SizedBox(width: TatoSpacing.xs),
                            Expanded(
                              child: _StatTile(
                                label: 'En riesgo',
                                value: '${insight.alertCount}',
                                color: insight.hasAlerts
                                    ? TatoColors.warning
                                    : TatoColors.success,
                              ),
                            ),
                            const SizedBox(width: TatoSpacing.xs),
                            Expanded(
                              child: _StatTile(label: 'Hoy', value: '$movementsToday'),
                            ),
                          ],
                        ),
                        if (insight.mostUrgentDepletion != null) ...[
                          const SizedBox(height: TatoSpacing.xl),
                          Text('TÁTO notó esto',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: TatoSpacing.sm),
                          _FeaturedInsightCard(
                            velocity: insight.mostUrgentDepletion!,
                            onViewDetail: () => context
                                .push('/inventory/${insight.mostUrgentDepletion!.product.id}'),
                          ),
                        ],
                        const SizedBox(height: TatoSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Movimientos recientes',
                                style: Theme.of(context).textTheme.titleLarge),
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
                              color: TatoColors.surface,
                              borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
                              border: Border.all(color: TatoColors.border),
                              boxShadow: TatoShadows.level1,
                            ),
                            child: Column(
                              children: recentMovements.take(4).toList().asMap().entries.map((e) {
                                return Column(
                                  children: [
                                    MovementTile(movement: e.value, showProductName: true),
                                    if (e.key < recentMovements.take(4).length - 1)
                                      const Divider(height: 1, indent: 16, endIndent: 16),
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
    );
  }
}

class _StatusHeroCard extends StatelessWidget {
  final StockInsight insight;

  const _StatusHeroCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final stable = !insight.hasAlerts;
    final color = stable ? TatoColors.success : TatoColors.warning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TatoSpacing.md),
      decoration: BoxDecoration(
        color: TatoColors.surface,
        borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
        border: Border.all(color: TatoColors.border),
        boxShadow: TatoShadows.level1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stable ? 'Tu inventario está estable' : 'Necesitas revisar tu inventario',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  stable
                      ? 'Sin alertas críticas por ahora.'
                      : '${insight.alertCount} producto(s) necesitan tu atención.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: TatoColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(stable ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                color: color),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatTile({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: TatoSpacing.sm),
      decoration: BoxDecoration(
        color: TatoColors.surface,
        borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
        border: Border.all(color: TatoColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  color: color ?? TatoColors.primary,
                ),
          ),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _FeaturedInsightCard extends StatelessWidget {
  final ProductVelocity velocity;
  final VoidCallback onViewDetail;

  const _FeaturedInsightCard({required this.velocity, required this.onViewDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TatoSpacing.md),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'ALERTA DE STOCK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TatoSpacing.sm),
          Text(
            velocity.product.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'podría agotarse en '
            '${velocity.estimatedDaysRemaining == 1 ? '1 día' : '${velocity.estimatedDaysRemaining} días'} '
            'según tus ventas recientes.',
            style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: TatoSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: TatoColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                ),
              ),
              onPressed: onViewDetail,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ver detalle', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
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
