import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/core/services/providers.dart';
import 'package:tato_app/shared/models/user.dart';
import 'package:tato_app/shared/widgets/custom_button.dart';

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
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Ingresa tu correo y contraseña para continuar.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Ingresa un correo electrónico válido.');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    // Simulated auth latency — no backend yet, this only creates a local
    // mock session so the rest of the app can be exercised end to end.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final name = email.split('@').first;
    ref.read(currentUserProvider.notifier).state = TatoUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name.isEmpty ? 'Usuario' : name[0].toUpperCase() + name.substring(1),
    );

    setState(() => _submitting = false);
    // GoRouter's redirect takes over from here (→ /setup-business o /hoy).
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
            children: [
              const SizedBox(height: TatoSpacing.xl),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: TatoColors.logoInk,
                  borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                ),
                child: const Center(
                  child: Text(
                    'T',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TatoSpacing.md),
              Text('TÁTO', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: TatoSpacing.lg),
              Text(
                'Bienvenido de vuelta',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: TatoSpacing.xs),
              Text(
                'Gestiona tu inventario con total confianza.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TatoColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: TatoSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TatoSpacing.lg),
                decoration: BoxDecoration(
                  color: TatoColors.surface,
                  borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
                  border: Border.all(color: TatoColors.border),
                  boxShadow: TatoShadows.level1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'tu@negocio.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: TatoSpacing.md),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outlined),
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
                        child: const Text('Olvidé mi contraseña'),
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
                      icon: Icons.arrow_forward_rounded,
                      loading: _submitting,
                      onPressed: _submitting ? null : _submit,
                    ),
                    const SizedBox(height: TatoSpacing.md),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: TatoSpacing.xs),
                          child: Text('o accede con',
                              style: Theme.of(context).textTheme.labelMedium),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: TatoSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _comingSoon('El acceso con Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: TatoColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                              ),
                            ),
                            child: const Text('Google'),
                          ),
                        ),
                        const SizedBox(width: TatoSpacing.sm),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _comingSoon('El acceso con Apple'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: TatoColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                              ),
                            ),
                            child: const Text('Apple'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TatoSpacing.md),
              TextButton(
                onPressed: _submitting ? null : _submit,
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
              const SizedBox(height: TatoSpacing.sm),
              Text(
                '© 2026 TÁTO · Tu inventario, sin complicarte.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
