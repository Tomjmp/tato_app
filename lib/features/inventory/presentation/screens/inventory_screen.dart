import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/features/category/domain/entities/category.dart';
import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/shared/widgets/empty_state.dart';
import 'package:tato_app/shared/widgets/product_card.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _search = '';
  String? _selectedCategory; // null = Todos
  Set<ProductStatus> _statusFilter = {}; // empty = no status filter
  late Future<List<Product>> _productsFuture;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  // Loaded once and refreshed explicitly (pull-to-refresh, or after
  // returning from a form) instead of on every rebuild — typing in the
  // search field must not re-trigger the mock network delay.
  void _loadProducts() {
    _productsFuture = ref.read(productRepositoryProvider).getProducts();
  }

  Future<void> _loadCategories() async {
    final businessId = ref.read(currentBusinessProvider)?.id;
    if (businessId == null) return;
    final categories = await ref.read(getCategoriesUseCaseProvider)(businessId);
    if (mounted) setState(() => _categories = categories);
  }

  Future<void> _refresh() async {
    setState(_loadProducts);
    await _productsFuture;
  }

  Future<void> _openStatusFilter() async {
    final result = await showModalBottomSheet<Set<ProductStatus>>(
      context: context,
      backgroundColor: TatoColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TatoSizes.radiusXl)),
      ),
      builder: (context) => _StatusFilterSheet(initial: _statusFilter),
    );
    if (result != null) setState(() => _statusFilter = result);
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TatoSizes.radiusLg)),
        title: const Text('¿Eliminar producto?'),
        content: Text('Se eliminará "${product.name}" del inventario.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: TatoColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(productRepositoryProvider).deleteProduct(product.id);
      if (mounted) _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatoColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TatoSpacing.containerPadding,
                vertical: TatoSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Inventario',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await context.push('/inventory/new');
                      if (mounted) _refresh();
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: TatoColors.primary,
                        borderRadius:
                            BorderRadius.circular(TatoSizes.radiusMd),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TatoSpacing.containerPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v.toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: 'Buscar producto…',
                        prefixIcon: Icon(Icons.search_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: TatoSpacing.xs),
                  GestureDetector(
                    onTap: _openStatusFilter,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _statusFilter.isEmpty
                            ? TatoColors.surface
                            : TatoColors.primary,
                        borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                        border: Border.all(
                          color: _statusFilter.isEmpty ? TatoColors.border : TatoColors.primary,
                        ),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: _statusFilter.isEmpty ? TatoColors.onSurfaceVariant : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TatoSpacing.sm),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: TatoSpacing.containerPadding,
                ),
                itemCount: _categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _FilterChip(
                      label: 'Todos',
                      selected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    );
                  }
                  final category = _categories[i - 1].name;
                  return _FilterChip(
                    label: category,
                    selected: _selectedCategory == category,
                    onTap: () => setState(() => _selectedCategory = category),
                  );
                },
              ),
            ),
            const SizedBox(height: TatoSpacing.sm),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('No se pudo cargar el inventario.'));
                  }
                  final all = snapshot.data ?? [];
                  var products = all;

                  if (_statusFilter.isNotEmpty) {
                    products =
                        products.where((p) => _statusFilter.contains(p.status)).toList();
                  }
                  if (_selectedCategory != null) {
                    products = products
                        .where((p) => p.categoryName == _selectedCategory)
                        .toList();
                  }
                  if (_search.isNotEmpty) {
                    products = products
                        .where((p) =>
                            p.name.toLowerCase().contains(_search) ||
                            (p.sku?.toLowerCase().contains(_search) ?? false))
                        .toList();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TatoSpacing.containerPadding,
                        ),
                        child: Text(
                          all.length == 1
                              ? '1 producto'
                              : '${all.length} productos',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(letterSpacing: 0),
                        ),
                      ),
                      const SizedBox(height: TatoSpacing.xs),
                      Expanded(
                        child: products.isEmpty
                            ? EmptyState(
                                icon: Icons.inventory_2_outlined,
                                title: 'Sin resultados',
                                subtitle: _search.isNotEmpty ||
                                        _selectedCategory != null ||
                                        _statusFilter.isNotEmpty
                                    ? 'Intenta con otra búsqueda o filtro.'
                                    : 'Agrega tu primer producto para empezar.',
                                actionLabel: _search.isEmpty &&
                                        _selectedCategory == null &&
                                        _statusFilter.isEmpty
                                    ? 'Agregar producto'
                                    : null,
                                onAction: _search.isEmpty &&
                                        _selectedCategory == null &&
                                        _statusFilter.isEmpty
                                    ? () async {
                                        await context.push('/inventory/new');
                                        if (mounted) _refresh();
                                      }
                                    : null,
                              )
                            : RefreshIndicator(
                                onRefresh: _refresh,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: TatoSpacing.containerPadding,
                                    vertical: TatoSpacing.sm,
                                  ),
                                  itemCount: products.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: TatoSpacing.sm),
                                  itemBuilder: (context, i) {
                                    final product = products[i];
                                    return ProductCard(
                                      product: product,
                                      onTap: () async {
                                        await context.push('/inventory/${product.id}');
                                        if (mounted) _refresh();
                                      },
                                      onEdit: () async {
                                        await context.push('/inventory/${product.id}/edit');
                                        if (mounted) _refresh();
                                      },
                                      onDelete: () => _deleteProduct(product),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterSheet extends StatefulWidget {
  final Set<ProductStatus> initial;

  const _StatusFilterSheet({required this.initial});

  @override
  State<_StatusFilterSheet> createState() => _StatusFilterSheetState();
}

class _StatusFilterSheetState extends State<_StatusFilterSheet> {
  late Set<ProductStatus> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(TatoSpacing.containerPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrar por estado', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: TatoSpacing.md),
            ...ProductStatus.values.map((status) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _selected.contains(status),
                  activeColor: TatoColors.primary,
                  title: Text(_statusLabel(status)),
                  onChanged: (checked) => setState(() {
                    if (checked == true) {
                      _selected.add(status);
                    } else {
                      _selected.remove(status);
                    }
                  }),
                )),
            const SizedBox(height: TatoSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(<ProductStatus>{}),
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: TatoSpacing.sm),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: TatoColors.primary),
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(ProductStatus status) {
    switch (status) {
      case ProductStatus.inStock:
        return 'Disponible';
      case ProductStatus.lowStock:
        return 'Bajo stock';
      case ProductStatus.outOfStock:
        return 'Agotado';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? TatoColors.onSurface : TatoColors.surface,
          borderRadius: BorderRadius.circular(TatoSizes.radiusPill),
          border: Border.all(
            color: selected ? TatoColors.onSurface : TatoColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : TatoColors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
