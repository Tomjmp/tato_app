import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/shared/widgets/error_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Loaded once instead of inside build() — this screen watches other
    // providers (e.g. notificationsEnabledProvider) that change on user
    // interaction, and re-fetching on every rebuild made the stat tiles
    // flash back to their loading state each time the switch was toggled.
    _productsFuture = ref.read(productRepositoryProvider).getProducts();
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
        ),
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Podrás volver a iniciar sesión cuando quieras.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: TatoColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(logoutUseCaseProvider)();
      // Business belongs to the session, not to auth itself — cleared
      // here in presentation, where cross-feature orchestration belongs.
      ref.read(currentBusinessProvider.notifier).state = null;
      ref.read(currentUserProvider.notifier).state = null;
      // GoRouter's redirect sends the user back to /login automatically.
    }
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disponible próximamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final business = ref.watch(currentBusinessProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: TatoColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TatoSpacing.containerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: TatoColors.primaryContainer,
                    child: Text(
                      user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: TatoColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: GestureDetector(
                      onTap: () => _comingSoon(context),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: TatoColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: TatoColors.background, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TatoSpacing.md),
              Text(
                user?.name ?? 'Usuario',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 2),
              Text(
                business?.name ?? user?.email ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: TatoColors.onSurfaceVariant),
              ),
              const SizedBox(height: TatoSpacing.lg),
              FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const ErrorState(
                      message: 'No se pudieron cargar tus estadísticas.',
                    );
                  }
                  final products = snapshot.data ?? const <Product>[];
                  final atRisk = products.where((p) => p.needsAttention).length;
                  return Row(
                    children: [
                      Expanded(
                        child: _StatTile(label: 'Productos', value: '${products.length}'),
                      ),
                      const SizedBox(width: TatoSpacing.sm),
                      Expanded(
                        child: _StatTile(
                          label: 'En riesgo',
                          value: '$atRisk',
                          color: atRisk > 0 ? TatoColors.warning : TatoColors.success,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: TatoSpacing.lg),
              if (business != null)
                _ListCard(
                  icon: Icons.storefront_outlined,
                  title: business.name,
                  subtitle: business.category,
                ),
              const SizedBox(height: TatoSpacing.sm),
              _ListCard(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones inteligentes',
                subtitle: 'Alertas de stock y reportes',
                trailing: Switch(
                  value: notificationsEnabled,
                  activeThumbColor: TatoColors.primary,
                  onChanged: (v) =>
                      ref.read(notificationsEnabledProvider.notifier).state = v,
                ),
              ),
              const SizedBox(height: TatoSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Sincronización', style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: TatoSpacing.sm),
              const _ListCard(
                icon: Icons.cloud_off_outlined,
                title: 'Modo offline activo',
                subtitle: 'Conecta con Supabase para sincronizar.',
              ),
              const SizedBox(height: TatoSpacing.lg),
              GestureDetector(
                onTap: () => _confirmLogout(context, ref),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TatoSpacing.md),
                  decoration: BoxDecoration(
                    color: TatoColors.surface,
                    borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
                    border: Border.all(color: TatoColors.error.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: TatoColors.error),
                      const SizedBox(width: TatoSpacing.sm),
                      Text(
                        'Cerrar sesión',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: TatoColors.error),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TatoSpacing.xl),
              Text(
                'TÁTO',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              Text(
                'Tu inventario, sin complicarte.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: TatoColors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text('v1.0.0 · MVP', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: TatoSpacing.xxl),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: TatoSpacing.md),
      decoration: BoxDecoration(
        color: TatoColors.surface,
        borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
        border: Border.all(color: TatoColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color ?? TatoColors.primary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: TatoColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _ListCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TatoColors.surfaceVariant,
              borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
            ),
            child: Icon(icon, color: TatoColors.onSurfaceVariant),
          ),
          const SizedBox(width: TatoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: TatoColors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          trailing ??
              const Icon(Icons.chevron_right, color: TatoColors.onSurfaceVariant),
        ],
      ),
    );
  }
}
