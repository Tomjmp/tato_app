import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:tato_app/shared/widgets/tato_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Primera vez → onboarding; después va directo al login.
  Future<void> _start(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(kOnboardingSeenKey) ?? false;
    if (!context.mounted) return;
    context.go(seen ? '/login' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TatoColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TatoSpacing.xl,
            vertical: TatoSpacing.lg,
          ),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const TatoLogo.onDark(size: 100),
              const SizedBox(height: TatoSpacing.lg),
              Text(
                'TÁTO',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 42,
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: TatoSpacing.xs),
              Text(
                'Tu inventario, sin complicarte.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.78),
                    ),
              ),
              const SizedBox(height: TatoSpacing.lg),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: TatoSpacing.xs,
                runSpacing: TatoSpacing.xs,
                children: [
                  _FeaturePill(icon: Icons.wifi_off_outlined, label: 'Offline'),
                  _FeaturePill(
                      icon: Icons.auto_awesome_outlined, label: 'IA on-device'),
                  _FeaturePill(
                      icon: Icons.notifications_outlined, label: 'Alertas'),
                ],
              ),
              const Spacer(flex: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(TatoSizes.radiusPill),
                    ),
                  ),
                  const SizedBox(width: 5),
                  _Dot(color: Colors.white.withOpacity(0.4)),
                  const SizedBox(width: 5),
                  _Dot(color: Colors.white.withOpacity(0.4)),
                ],
              ),
              const SizedBox(height: TatoSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => _start(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: TatoColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
                    ),
                  ),
                  child: const Text(
                    'Empezar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: TatoSpacing.md),
              Text(
                'Ayuda   ·   Términos   ·   Español',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(TatoSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
