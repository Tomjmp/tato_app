import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/tato_constants.dart';

class TatoTheme {
  TatoTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
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
        background: TatoColors.background,
        onBackground: TatoColors.onBackground,
        surface: TatoColors.surface,
        onSurface: TatoColors.onSurface,
        surfaceVariant: TatoColors.surfaceVariant,
        onSurfaceVariant: TatoColors.onSurfaceVariant,
        outline: TatoColors.outline,
      ),
      // Space Grotesk for headlines and numbers (data is the protagonist),
      // Inter for everything read at body/label size. See design/DESIGN_SYSTEM.md.
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            color: TatoColors.onSurface,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: TatoColors.onSurface,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: TatoColors.onSurfaceVariant,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: TatoColors.onSurface,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: TatoColors.onSurfaceVariant,
          ),
        ),
      ).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
          color: TatoColors.onSurface,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: TatoColors.onSurface,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: TatoColors.onSurface,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: TatoColors.onSurface,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TatoColors.onSurface,
        ),
      ),
      scaffoldBackgroundColor: TatoColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: TatoColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: TatoColors.onSurface),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: TatoColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: const CardThemeData(
        color: TatoColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(TatoSizes.radiusXl),
          ),
          side: BorderSide(color: TatoColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: TatoColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: TatoSpacing.md,
          vertical: TatoSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(TatoSizes.radiusMd),
          ),
          borderSide: BorderSide(color: TatoColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(TatoSizes.radiusMd),
          ),
          borderSide: BorderSide(color: TatoColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(TatoSizes.radiusMd),
          ),
          borderSide: BorderSide(color: TatoColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(TatoSizes.radiusMd),
          ),
          borderSide: BorderSide(color: TatoColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(TatoSizes.radiusMd),
          ),
          borderSide: BorderSide(color: TatoColors.error, width: 2),
        ),
        labelStyle: TextStyle(
          color: TatoColors.onSurfaceVariant,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: TatoColors.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: TatoColors.surface,
        indicatorColor: TatoColors.secondaryContainer,
        elevation: 8,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TatoColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: TatoColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: TatoColors.onSecondaryContainer,
              size: 24,
            );
          }
          return const IconThemeData(
            color: TatoColors.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: TatoColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
