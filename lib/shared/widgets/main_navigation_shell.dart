import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tato_app/core/constants/tato_constants.dart';

class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/inventory')) return 1;
    if (location.startsWith('/scan')) return 2;
    if (location.startsWith('/insights')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // /hoy
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/hoy');
      case 1:
        context.go('/inventory');
      case 2:
        context.go('/scan');
      case 3:
        context.go('/insights');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: TatoColors.surface,
          border: Border(
            top: BorderSide(color: TatoColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Hoy',
                  selected: selectedIndex == 0,
                  onTap: () => _onNavTap(context, 0),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2,
                  label: 'Inventario',
                  selected: selectedIndex == 1,
                  onTap: () => _onNavTap(context, 1),
                ),
                _ScanButton(onTap: () => _onNavTap(context, 2)),
                _NavItem(
                  icon: Icons.insights_outlined,
                  selectedIcon: Icons.insights,
                  label: 'Insights',
                  selected: selectedIndex == 3,
                  onTap: () => _onNavTap(context, 3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Perfil',
                  selected: selectedIndex == 4,
                  onTap: () => _onNavTap(context, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? TatoColors.primary : TatoColors.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Escanear es la feature diferenciadora: tile azul elevado sobre la barra,
/// en el lugar del pulgar, siempre visible aunque no sea la tab activa.
class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -16),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: TatoColors.primary,
                borderRadius: BorderRadius.circular(TatoSizes.radiusLg),
                border: Border.all(color: TatoColors.background, width: 4),
              ),
              child: const Icon(Icons.qr_code_scanner_outlined,
                  color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
