import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/features/inventory/domain/entities/product.dart';
import 'package:tato_app/shared/widgets/custom_button.dart';
import 'package:tato_app/shared/widgets/product_avatar.dart';
import 'package:tato_app/shared/widgets/tato_app_bar.dart';

/// Create/edit form for a product. When [productId] is null this creates
/// a new product; otherwise it loads and updates the existing one.
class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;

  /// Pre-selected category, e.g. coming from the standalone Scan tab.
  final String? initialCategory;

  const ProductFormScreen({super.key, this.productId, this.initialCategory});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '5');

  String? _category;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Product? _existing;

  bool get _isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _load();
  }

  Future<void> _load() async {
    if (widget.productId == null) {
      setState(() => _loading = false);
      return;
    }
    final product =
        await ref.read(productRepositoryProvider).getProductById(widget.productId!);
    if (!mounted) return;
    if (product != null) {
      _existing = product;
      _nameController.text = product.name;
      _skuController.text = product.sku ?? '';
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toStringAsFixed(2);
      _costController.text = product.cost.toStringAsFixed(2);
      _stockController.text = product.currentStock.toStringAsFixed(0);
      _minStockController.text = product.minStockAlert.toStringAsFixed(0);
      _category = product.categoryName;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _openScanner() async {
    final suggested = await context.push<String>('/scanner');
    if (suggested != null && mounted) {
      setState(() => _category = suggested);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final cost = double.tryParse(_costController.text.trim());
    final stock = double.tryParse(_stockController.text.trim());
    final minStock = double.tryParse(_minStockController.text.trim());

    if (name.isEmpty) {
      setState(() => _error = 'Ingresa el nombre del producto.');
      return;
    }
    if (_category == null) {
      setState(() => _error = 'Selecciona una categoría.');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _error = 'Ingresa un precio de venta válido.');
      return;
    }
    if (cost == null || cost < 0) {
      setState(() => _error = 'Ingresa un costo válido.');
      return;
    }
    if (stock == null || stock < 0) {
      setState(() => _error = 'Ingresa un stock inicial válido.');
      return;
    }
    if (minStock == null || minStock < 0) {
      setState(() => _error = 'Ingresa una alerta de stock mínimo válida.');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final now = DateTime.now();
    final business = ref.read(currentBusinessProvider);
    final product = Product(
      localId: _existing?.localId ?? const Uuid().v4(),
      cloudId: _existing?.cloudId,
      businessId: _existing?.businessId ?? business?.localId ?? 'biz-local',
      name: name,
      description:
          _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
      categoryId: _category,
      categoryName: _category,
      imageUrl: _existing?.imageUrl,
      price: price,
      cost: cost,
      currentStock: stock,
      minStockAlert: minStock,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
      synced: false,
    );

    await ref.read(productRepositoryProvider).saveProduct(product);
    setState(() => _saving = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatoColors.background,
      appBar: TatoAppBar(title: _isEditing ? 'Editar producto' : 'Nuevo producto'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(TatoSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        ProductAvatar(
                          imageUrl: _existing?.imageUrl,
                          categoryName: _category,
                          size: 84,
                          radius: TatoSizes.radiusXl,
                        ),
                        const SizedBox(height: TatoSpacing.sm),
                        TextButton.icon(
                          onPressed: _openScanner,
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text('Escanear producto con IA'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TatoSpacing.sm),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                      hintText: 'Ej. Shampoo L\'Oreal Elvive',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: TatoSpacing.md),
                  TextField(
                    controller: _skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU (opcional)',
                      prefixIcon: Icon(Icons.qr_code_outlined),
                    ),
                  ),
                  const SizedBox(height: TatoSpacing.md),
                  Text('Categoría', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: TatoSpacing.sm),
                  Wrap(
                    spacing: TatoSpacing.xs,
                    runSpacing: TatoSpacing.xs,
                    children: TatoCategories.businessTypes.map((type) {
                      final selected = _category == type;
                      final color = TatoCategories.colorFor(type);
                      return GestureDetector(
                        onTap: () => setState(() => _category = type),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? color.withOpacity(0.12) : TatoColors.surface,
                            borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                            border: Border.all(
                              color: selected ? color : TatoColors.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(TatoCategories.iconFor(type),
                                  size: 15, color: selected ? color : TatoColors.onSurfaceVariant),
                              const SizedBox(width: 5),
                              Text(
                                type,
                                style: TextStyle(
                                  color: selected ? color : TatoColors.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: TatoSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Precio de venta',
                            prefixText: 'RD\$ ',
                          ),
                        ),
                      ),
                      const SizedBox(width: TatoSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _costController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Costo',
                            prefixText: 'RD\$ ',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TatoSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _stockController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Stock inicial',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: TatoSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _minStockController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Alerta mínima',
                            prefixIcon: Icon(Icons.warning_amber_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TatoSpacing.md),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
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
                    label: _isEditing ? 'Guardar cambios' : 'Guardar producto',
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
