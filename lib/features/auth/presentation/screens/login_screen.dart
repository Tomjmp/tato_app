import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/shared/widgets/custom_button.dart';
import 'package:tato_app/shared/widgets/tato_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature estará disponible próximamente.')),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      final user = await ref.read(loginUseCaseProvider)(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      ref.read(currentUserProvider.notifier).state = user;

      // If this user already has a business (e.g. returning session),
      // pick it up now instead of sending them through setup again.
      // The mock repository has no cross-session persistence, so this is
      // always null today — it's here so the real check needs no rewrite.
      final business = await ref.read(getBusinessUseCaseProvider)(userId: user.id);
      if (!mounted) return;
      if (business != null) {
        ref.read(currentBusinessProvider.notifier).state = business;
      }
      // GoRouter's redirect takes over from here (→ /setup-business o /hoy).
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
      backgroundColor: TatoColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: TatoSpacing.containerPadding,
            vertical: TatoSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TatoSpacing.md),
              const TatoLogo(size: 52),
              const SizedBox(height: TatoSpacing.lg),
              Text(
                'Hola de nuevo',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: TatoSpacing.unit),
              Text(
                'Entra para ver cómo va tu negocio.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TatoSpacing.lg),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  hintText: 'karla@negocio.do',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: TatoSpacing.md),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _comingSoon('La recuperación de contraseña'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: TatoSpacing.xs),
                Text(
                  _error!,
                  style: const TextStyle(color: TatoColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: TatoSpacing.sm),
              CustomButton(
                label: 'Iniciar sesión',
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: TatoSpacing.md),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: TatoSpacing.xs),
                    child: Text('o',
                        style: Theme.of(context).textTheme.labelMedium),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: TatoSpacing.md),
              CustomButton(
                label: 'Crear cuenta gratis',
                variant: CustomButtonVariant.outline,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: TatoSpacing.xl),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TatoColors.mintTint,
                    borderRadius: BorderRadius.circular(TatoSizes.radiusPill),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_outlined,
                          size: 13, color: TatoColors.onMintTint),
                      SizedBox(width: 5),
                      Text(
                        'Funciona sin internet',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: TatoColors.onMintTint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TatoSpacing.sm),
              Center(
                child: Text(
                  '© 2026 TÁTO · Tu inventario, sin complicarte.',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
