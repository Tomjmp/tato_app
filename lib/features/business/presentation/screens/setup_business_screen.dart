import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/shared/models/business.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Ingresa el nombre de tu negocio.');
      return;
    }
    if (_selectedType == null) {
      setState(() => _error = 'Selecciona el tipo de negocio.');
      return;
    }

    final user = ref.read(currentUserProvider);
    final now = DateTime.now();
    ref.read(currentBusinessProvider.notifier).state = Business(
      localId: 'biz-${now.millisecondsSinceEpoch}',
      cloudId: null,
      userId: user?.id ?? 'user-local',
      name: name,
      category: _selectedType!,
      currency: 'DOP',
      createdAt: now,
      updatedAt: now,
      synced: false,
    );
    if (mounted) context.go('/hoy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatoColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: TatoSpacing.containerPadding,
            vertical: TatoSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TatoSpacing.lg),
              Text(
                'Configura tu negocio',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: TatoSpacing.xs),
              Text(
                'TÁTO necesita conocer tu negocio para darte mejores insights.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TatoColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: TatoSpacing.xxl),
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
                  final color = TatoCategories.colorFor(type);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
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
                              size: 16, color: selected ? color : TatoColors.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            type,
                            style: TextStyle(
                              color: selected ? color : TatoColors.onSurfaceVariant,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
              CustomButton(label: 'Comenzar', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
