import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/tato_constants.dart';

class TatoTheme {
  TatoTheme._();

  /// Ambos temas nacen del mismo seed (el azul de marca) vía
  /// ColorScheme.fromSeed y luego se ajustan los roles clave para que la
  /// paleta coincida con design/DESIGN_SYSTEM.md. Todo lo demás se deriva
  /// del scheme, así light y dark comparten una sola definición.
  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: TatoColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: TatoColors.primary,
      onPrimary: TatoColors.onPrimary,
      primaryContainer: TatoColors.primaryContainer,
      onPrimaryContainer: TatoColors.onPrimaryContainer,
      secondary: TatoColors.secondary,
      onSecondary: TatoColors.onSecondary,
      secondaryContainer: TatoColors.secondaryContainer,
      onSecondaryContainer: TatoColors.onSecondaryContainer,
      tertiary: TatoColors.tertiary,
      onTertiary: TatoColors.onTertiary,
      tertiaryContainer: TatoColors.tertiaryContainer,
      onTertiaryContainer: TatoColors.onTertiaryContainer,
      error: TatoColors.error,
      onError: Colors.white,
      surface: TatoColors.surface,
      onSurface: TatoColors.onSurface,
      onSurfaceVariant: TatoColors.onSurfaceVariant,
      outline: TatoColors.outline,
      outlineVariant: TatoColors.border,
    );
    return _base(scheme, scaffold: TatoColors.background);
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: TatoColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF8FB3FF),
      onPrimary: const Color(0xFF0B2A6B),
      primaryContainer: const Color(0xFF1E3A8A),
      onPrimaryContainer: const Color(0xFFDBEAFE),
      secondary: const Color(0xFF2DD4BF),
      onSecondary: const Color(0xFF03312B),
      secondaryContainer: const Color(0xFF115E59),
      onSecondaryContainer: const Color(0xFFCCFBF1),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF450A0A),
      surface: const Color(0xFF1E293B),
      onSurface: const Color(0xFFE2E8F0),
      onSurfaceVariant: const Color(0xFF94A3B8),
      outline: const Color(0xFF475569),
      outlineVariant: const Color(0xFF334155),
    );
    return _base(scheme, scaffold: const Color(0xFF0F172A));
  }

  static ThemeData _base(ColorScheme scheme, {required Color scaffold}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Transición M3 (zoom) en Android; deslizamiento suave en el resto.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      // Space Grotesk for headlines and numbers (data is the protagonist),
      // Inter for everything read at body/label size. See design/DESIGN_SYSTEM.md.
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            color: scheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: scheme.onSurface,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: scheme.onSurfaceVariant,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: scheme.onSurface,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
          color: scheme.onSurface,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: scheme.onSurface,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: scheme.onSurface,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: scheme.onSurface,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(TatoSizes.radiusXl)),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TatoSpacing.md,
          vertical: TatoSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(TatoSizes.radiusMd)),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(TatoSizes.radiusMd)),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(TatoSizes.radiusMd)),
          borderSide: BorderSide(color: scheme.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(TatoSizes.radiusMd)),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(TatoSizes.radiusMd)),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: scheme.onSecondaryContainer,
              size: 24,
            );
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(TatoSizes.radiusMd)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
