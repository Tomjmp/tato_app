import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/shared/widgets/custom_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatoColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TatoSpacing.xl,
            vertical: TatoSpacing.xl,
          ),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: TatoColors.logoInk,
                  borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
                ),
                child: const Center(
                  child: Text(
                    'T',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TatoSpacing.lg),
              Text(
                'TÁTO',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(height: TatoSpacing.sm),
              Text(
                'Tu inventario, sin complicarte.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: TatoSpacing.md),
              Text(
                'Controla productos, registra movimientos\ny recibe alertas inteligentes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: TatoSpacing.lg),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: TatoSpacing.xs,
                runSpacing: TatoSpacing.xs,
                children: [
                  _FeaturePill(icon: Icons.check_circle_outline, label: 'Simplicidad Total'),
                  _FeaturePill(icon: Icons.notifications_outlined, label: 'Alertas'),
                  _FeaturePill(icon: Icons.show_chart_outlined, label: 'Data'),
                ],
              ),
              const Spacer(flex: 4),
              CustomButton(
                label: 'Crear cuenta',
                onPressed: () => context.go('/login'),
                icon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: TatoSpacing.sm),
              CustomButton(
                label: 'Iniciar sesión',
                onPressed: () => context.go('/login'),
                variant: CustomButtonVariant.outline,
              ),
              const SizedBox(height: TatoSpacing.lg),
              Text(
                'Ayuda   ·   Términos   ·   Español',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TatoColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: TatoColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: TatoColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TatoColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
