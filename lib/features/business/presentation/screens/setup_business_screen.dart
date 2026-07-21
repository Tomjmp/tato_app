import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/shared/widgets/custom_button.dart';

class SetupBusinessScreen extends ConsumerStatefulWidget {
  const SetupBusinessScreen({super.key});

  @override
  ConsumerState<SetupBusinessScreen> createState() => _SetupBusinessScreenState();
}

class _SetupBusinessScreenState extends ConsumerState<SetupBusinessScreen> {
  final _nameController = TextEditingController();
  String? _selectedType;
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      final userId = ref.read(currentUserProvider)?.id ?? 'user-local';
      final business = await ref.read(createBusinessUseCaseProvider)(
        userId: userId,
        name: _nameController.text,
        category: _selectedType,
      );
      if (!mounted) return;
      ref.read(currentBusinessProvider.notifier).state = business;

      // Seed the default product categories for this business now, so
      // Stock/ProductForm/Scanner have something real to read from.
      await ref.read(seedDefaultCategoriesUseCaseProvider)(businessId: business.id);
      if (!mounted) return;
      context.go('/hoy');
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() => _error = f.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: TatoSpacing.containerPadding,
            vertical: TatoSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paso 2 de 2',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: TatoSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(TatoSizes.radiusPill),
                child: LinearProgressIndicator(
                  value: 1,
                  minHeight: 5,
                  backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                  color: TatoColors.primary,
                ),
              ),
              const SizedBox(height: TatoSpacing.lg),
              Text(
                'Crea tu negocio',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TatoSpacing.xs),
              Text(
                'Así TÁTO personaliza tus categorías y alertas.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TatoSpacing.xl),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del negocio',
                  hintText: 'Ej. Belleza Total RD',
                  prefixIcon: Icon(Icons.store_outlined),
                ),
              ),
              const SizedBox(height: TatoSpacing.lg),
              Text('Tipo de negocio', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TatoSpacing.sm),
              Wrap(
                spacing: TatoSpacing.xs,
                runSpacing: TatoSpacing.xs,
                children: TatoCategories.businessTypes.map((type) {
                  final selected = _selectedType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? TatoColors.primary : Theme.of(context).colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(TatoSizes.radiusPill),
                        border: Border.all(
                          color:
                              selected ? TatoColors.primary : Theme.of(context).colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(TatoCategories.iconFor(type),
                              size: 16,
                              color: selected
                                  ? Colors.white
                                  : TatoColors.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            type,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : TatoColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_error != null) ...[
                const SizedBox(height: TatoSpacing.md),
                Text(
                  _error!,
                  style: const TextStyle(color: TatoColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: TatoSpacing.xxl),
              CustomButton(
                label: 'Crear mi negocio',
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: TatoSpacing.sm),
              Center(
                child: Text(
                  'Podrás editarlo cuando quieras.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
