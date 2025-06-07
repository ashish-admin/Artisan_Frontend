// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Core Palette
  static const Color nearBlack = Color(0xFF121212);
  static const Color offWhite = Color(0xFFE0E0E0);
  static const Color mediumGrey = Color(0xFF8A8A8A);
  static const Color accentBlue = Color(0xFF64B5F6);

  // Surface & Container Colors
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceContainer = Color(0xFF222327);
  static const Color surfaceContainerHigh = Color(0xFF2C2D31);
  static const Color surfaceContainerHighest = Color(0xFF37383C);
  static const Color dialogBackgroundColor = Color(0xFF222222);

  // Helper to convert opacity (0.0-1.0) to alpha (0-255)
  static int _alphaFromOpacity(double opacity) {
    if (opacity < 0.0) opacity = 0.0;
    if (opacity > 1.0) opacity = 1.0;
    return (opacity * 255).round();
  }

  static ThemeData get artisanTheme {
    // CORRECTED: Use 'surface' and 'onSurface' instead of deprecated properties.
    final baseColorScheme = ColorScheme.dark(
      primary: accentBlue,
      onPrimary: nearBlack,
      secondary: accentBlue,
      onSecondary: nearBlack,
      surface: surface,
      onSurface: offWhite,
      error: Colors.red.shade300,
      onError: nearBlack,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: mediumGrey,
      outline: mediumGrey.withAlpha(_alphaFromOpacity(0.5)),
    );

    const artisanTextTheme = TextTheme(
      displayLarge: TextStyle(color: offWhite, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      headlineMedium: TextStyle(color: offWhite, fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: offWhite, fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: offWhite, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      bodyLarge: TextStyle(color: offWhite, fontSize: 16, height: 1.5, letterSpacing: 0.5),
      bodyMedium: TextStyle(color: mediumGrey, fontSize: 14, height: 1.4, letterSpacing: 0.25),
      bodySmall: TextStyle(color: mediumGrey, fontSize: 12, height: 1.3, letterSpacing: 0.4),
      labelLarge: TextStyle(color: offWhite, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: baseColorScheme.surface, // Use surface instead of background
      textTheme: artisanTextTheme,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: offWhite),
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseColorScheme.primary,
          foregroundColor: baseColorScheme.onPrimary,
          textStyle: artisanTextTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(64, 50),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: baseColorScheme.primary,
          side: BorderSide(color: baseColorScheme.outline, width: 1.5),
          textStyle: artisanTextTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(64, 50),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer, // Corrected: Using a defined color
        hintStyle: TextStyle(color: mediumGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: accentBlue, width: 2),
        ),
        labelStyle: TextStyle(color: mediumGrey),
        floatingLabelStyle: TextStyle(color: accentBlue),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: baseColorScheme.primary.withAlpha(_alphaFromOpacity(0.12)),
        selectedColor: baseColorScheme.primary,
        labelStyle: const TextStyle(color: offWhite, fontSize: 14, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: nearBlack, fontSize: 14, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceContainer, // Corrected: Using a defined color
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          side: BorderSide(color: baseColorScheme.outline.withAlpha(_alphaFromOpacity(0.7))),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: dialogBackgroundColor,
        elevation: 3,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        titleTextStyle: artisanTextTheme.headlineSmall,
        contentTextStyle: artisanTextTheme.bodyLarge,
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        backgroundColor: surfaceContainerHighest,
        actionTextColor: accentBlue,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) return baseColorScheme.primary;
          return mediumGrey;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) return baseColorScheme.primary.withAlpha(_alphaFromOpacity(0.5));
          return null; 
        }),
      ),
    );
  }
}