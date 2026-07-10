import 'package:flutter/material.dart';

class TatoCategories {
  TatoCategories._();

  static const List<String> businessTypes = [
    'Belleza',
    'Alimentos',
    'Bebidas',
    'Ropa',
    'Accesorios',
    'Colmado',
    'Otro',
  ];

  static IconData iconFor(String? category) {
    switch (category) {
      case 'Belleza':
        return Icons.auto_awesome_outlined;
      case 'Alimentos':
        return Icons.restaurant_outlined;
      case 'Bebidas':
        return Icons.local_cafe_outlined;
      case 'Ropa':
        return Icons.checkroom_outlined;
      case 'Accesorios':
        return Icons.diamond_outlined;
      case 'Colmado':
        return Icons.storefront_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  static Color colorFor(String? category) {
    switch (category) {
      case 'Belleza':
        return const Color(0xFFEC4899);
      case 'Alimentos':
        return const Color(0xFFF59E0B);
      case 'Bebidas':
        return const Color(0xFF3B82F6);
      case 'Ropa':
        return const Color(0xFF8B5CF6);
      case 'Accesorios':
        return const Color(0xFF14B8A6);
      case 'Colmado':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }
}

class TatoColors {
  TatoColors._();

  // Primary palette
  static const Color primary = Color(0xFF1D4ED8); // Vivid commercial blue
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color onPrimaryContainer = Color(0xFF1E3A8A);

  // Reserved for the "T" logo mark only (Splash/Login) — stays dark navy
  // while the rest of the UI moved to the vivid blue above.
  static const Color logoInk = Color(0xFF0F172A);

  // Secondary palette
  static const Color secondary = Color(0xFF14B8A6); // Modern Teal
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondaryContainer = Color(0xFF115E59);

  // Tertiary / Accents
  static const Color tertiary = Color(0xFF0D9488); 
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFFD1FAE5); // Soft Mint
  static const Color onTertiaryContainer = Color(0xFF065F46);

  // Status & Feedback colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Warm Amber (Low stock)
  static const Color error = Color(0xFFEF4444); // Soft Coral (Out of stock/error)
  static const Color info = Color(0xFF3B82F6); // Blue

  // Neutrals / Surfaces
  static const Color background = Color(0xFFF8FAFC); // Clean light grey background
  static const Color onBackground = Color(0xFF0F172A);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF0F172A);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  
  static const Color border = Color(0xFFE2E8F0); // Subtle divider / field border
  static const Color outline = Color(0xFFCBD5E1);
}

class TatoSpacing {
  TatoSpacing._();

  static const double unit = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double containerPadding = 20.0;
  static const double stackGap = 16.0;
  static const double sectionMargin = 32.0;
}

class TatoSizes {
  TatoSizes._();

  static const double radiusSm = 4.0;
  static const double radiusDefault = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  static const double minTouchTarget = 48.0;
}

class TatoShadows {
  TatoShadows._();

  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0A0F172A), // 4% opacity indigo
      blurRadius: 12.0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x140F172A), // 8% opacity indigo
      blurRadius: 20.0,
      offset: Offset(0, 8),
    ),
  ];
}
