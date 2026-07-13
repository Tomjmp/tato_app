import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';
import 'package:tato_app/shared/widgets/custom_button.dart';
import 'package:tato_app/shared/widgets/product_avatar.dart';
import 'package:tato_app/shared/widgets/quantity_stepper.dart';
import 'package:tato_app/shared/widgets/segmented_control.dart';

class NewMovementScreen extends ConsumerStatefulWidget {
  final String? initialProductId;

  const NewMovementScreen({super.key, this.initialProductId});

  @override
  ConsumerState<NewMovementScreen> createState() => _NewMovementScreenState();
}

class _NewMovementScreenState extends ConsumerState<NewMovementScreen> {
  MovementType _type = MovementType.entry;
  bool _increasesStock = true; // only relevant for MovementType.adjustment
  Product? _selectedProduct;
  String _productSearch = '';
  String _reason = 'Compra';
  int _quantity = 1;
  final _productSearchController = TextEditingController();
  final _noteController = TextEditingController();
  bool _saving = false;
  bool _loadingProducts = true;
  String? _error;
  String? _loadError;
  List<Product> _allProducts = [];

  static const _exitReasons = ['Venta', 'Merma', 'Devolución', 'Otro'];
  static const _entryReasons = ['Compra', 'Devolución', 'Producción', 'Otro'];
  static const _adjustmentReasons = [
    'Conteo físico',
    'Producto dañado',
    'Corrección de error',
    'Otro',
  ];

  List<String> get _reasons {
    switch (_type) {
      case MovementType.exit:
        return _exitReasons;
      case MovementType.entry:
        return _entryReasons;
      case MovementType.adjustment:
        return _adjustmentReasons;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await ref.read(productRepositoryProvider).getProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        _loadingProducts = false;
        if (widget.initialProductId != null) {
          final match = products.where((p) => p.id == widget.initialProductId).toList();
          if (match.isNotEmpty) _selectedProduct = match.first;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingProducts = false;
        _loadError = 'No se pudo cargar la lista de productos.';
      });
    }
  }

  @override
  void dispose() {
    _productSearchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setType(MovementType type, String defaultReason) {
    setState(() {
      _type = type;
      _reason = defaultReason;
      _error = null;
    });
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        'Entrada: agrega stock. Salida: descuenta stock. '
        'Ajuste: corrige el stock por conteo físico u otra razón.',
      ),
    ));
  }

  Future<void> _save() async {
    if (_selectedProduct == null) {
      setState(() => _error = 'Selecciona un producto.');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final now = DateTime.now();
    final movement = InventoryMovement(
      id: const Uuid().v4(),
      productId: _selectedProduct!.id,
      productName: _selectedProduct!.name,
      type: _type,
      quantity: _quantity.toDouble(),
      reason: _reason,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      increasesStock: _type == MovementType.adjustment ? _increasesStock : null,
      date: now,
      createdAt: now,
      updatedAt: now,
      synced: false,
    );

    try {
      await ref.read(registerMovementUseCaseProvider)(movement);
      setState(() => _saving = false);
      if (mounted) context.pop();
    } on Failure catch (f) {
      setState(() {
        _saving = false;
        _error = f.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatoColors.background,
      appBar: AppBar(
        backgroundColor: TatoColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('TÁTO', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TatoSpacing.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registrar Movimiento', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'Gestiona el flujo de inventario con precisión.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: TatoColors.onSurfaceVariant),
            ),
            const SizedBox(height: TatoSpacing.lg),
            SegmentedControl<MovementType>(
              selected: _type,
              onChanged: (type) => _setType(
                type,
                type == MovementType.exit
                    ? 'Venta'
                    : type == MovementType.entry
                        ? 'Compra'
                        : 'Conteo físico',
              ),
              options: const [
                SegmentOption(value: MovementType.entry, label: 'Entrada'),
                SegmentOption(value: MovementType.exit, label: 'Salida'),
                SegmentOption(value: MovementType.adjustment, label: 'Ajuste'),
              ],
            ),
            if (_type == MovementType.adjustment) ...[
              const SizedBox(height: TatoSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _MiniToggle(
                      label: 'Aumentar stock',
                      selected: _increasesStock,
                      color: TatoColors.success,
                      onTap: () => setState(() => _increasesStock = true),
                    ),
                  ),
                  const SizedBox(width: TatoSpacing.sm),
                  Expanded(
                    child: _MiniToggle(
                      label: 'Disminuir stock',
                      selected: !_increasesStock,
                      color: TatoColors.error,
                      onTap: () => setState(() => _increasesStock = false),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: TatoSpacing.lg),
            Text('PRODUCTO',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(letterSpacing: 0.5)),
            const SizedBox(height: TatoSpacing.sm),
            if (_selectedProduct == null) ...[
              TextField(
                controller: _productSearchController,
                onChanged: (v) => setState(() => _productSearch = v.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Buscar producto...',
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),
              if (_loadingProducts)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: TatoSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                Padding(
                  padding: const EdgeInsets.only(top: TatoSpacing.sm),
                  child: Text(
                    _loadError!,
                    style: const TextStyle(color: TatoColors.error, fontSize: 13),
                  ),
                )
              else if (_productSearch.isNotEmpty)
                ..._allProducts
                    .where((p) => p.name.toLowerCase().contains(_productSearch))
                    .take(5)
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(top: TatoSpacing.xs),
                          child: _ProductResultTile(
                            product: p,
                            onTap: () => setState(() {
                              _selectedProduct = p;
                              _productSearchController.clear();
                              _productSearch = '';
                            }),
                          ),
                        )),
            ] else
              _SelectedProductCard(
                product: _selectedProduct!,
                onClear: () => setState(() => _selectedProduct = null),
              ),
            const SizedBox(height: TatoSpacing.md),
            Text('CANTIDAD',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(letterSpacing: 0.5)),
            const SizedBox(height: TatoSpacing.sm),
            QuantityStepper(
              value: _quantity,
              onChanged: (v) => setState(() => _quantity = v),
            ),
            const SizedBox(height: TatoSpacing.md),
            Text('Razón', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TatoSpacing.sm),
            Wrap(
              spacing: TatoSpacing.xs,
              children: _reasons
                  .map((r) => _ReasonChip(
                        label: r,
                        selected: _reason == r,
                        onTap: () => setState(() => _reason = r),
                      ))
                  .toList(),
            ),
            const SizedBox(height: TatoSpacing.md),
            Text('NOTA (OPCIONAL)',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(letterSpacing: 0.5)),
            const SizedBox(height: TatoSpacing.sm),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ej. Reabastecimiento semanal...',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: TatoSpacing.sm),
              Text(
                _error!,
                style: const TextStyle(color: TatoColors.error, fontSize: 13),
              ),
            ],
            const SizedBox(height: TatoSpacing.xl),
            CustomButton(
              label: 'Guardar movimiento',
              icon: Icons.save_outlined,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: TatoSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ProductResultTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductResultTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TatoSpacing.sm),
        decoration: BoxDecoration(
          color: TatoColors.surface,
          borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
          border: Border.all(color: TatoColors.border),
        ),
        child: Row(
          children: [
            ProductAvatar(
              imageUrl: product.imageUrl,
              categoryName: product.categoryName,
              size: 36,
              radius: TatoSizes.radiusSm,
            ),
            const SizedBox(width: TatoSpacing.sm),
            Expanded(
              child: Text(product.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis),
            ),
            Text('${product.currentStock.toInt()} uds.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: TatoColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SelectedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onClear;

  const _SelectedProductCard({required this.product, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TatoSpacing.md),
      decoration: BoxDecoration(
        color: TatoColors.surface,
        borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
        border: Border.all(color: TatoColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ProductAvatar(
            imageUrl: product.imageUrl,
            categoryName: product.categoryName,
            size: 44,
          ),
          const SizedBox(width: TatoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis),
                Text('Stock actual: ${product.currentStock.toInt()} unidades',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: TatoColors.onSurfaceVariant)),
              ],
            ),
          ),
          if (product.sku != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: TatoColors.surfaceVariant,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('ID: ${product.sku}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _MiniToggle({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : TatoColors.surfaceVariant,
          borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : TatoColors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ReasonChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor:
            selected ? TatoColors.primaryContainer : TatoColors.surfaceVariant,
        labelStyle: TextStyle(
          color: selected ? TatoColors.onPrimaryContainer : TatoColors.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
        ),
        side: BorderSide.none,
      ),
    );
  }
}
