// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Core Palette
  static final Color nearBlack = Color(0xFF121212); // Main background
  static final Color offWhite = Color(0xFFE0E0E0);   // Primary text on dark
  static final Color mediumGrey = Color(0xFF8A8A8A);  // Secondary text, hints, disabled
  static final Color accentBlue = Color(0xFF64B5F6); // Main accent (Material Blue 300 for good dark theme contrast)
  
  // Surface & Container Colors (Material 3 inspired)
  // These provide slight variations for different UI layers.
  static final Color surface = Color(0xFF1E1E1E); // Slightly lighter than nearBlack for cards, dialogs if needed
  static final Color surfaceContainer = Color(0xFF222327); // A step above surface
  static final Color surfaceContainerHigh = Color(0xFF2C2D31); // Higher emphasis surface
  static final Color surfaceContainerHighest = Color(0xFF37383C); // Highest emphasis surface

  // Error Colors
  static final Color errorColor = Colors.red.shade300; // Error color itself
  static final Color onErrorColor = nearBlack; // Text/icons on error color

  // Helper to convert opacity (0.0-1.0) to alpha (0-255)
  static int _alphaFromOpacity(double opacity) {
    if (opacity < 0.0) opacity = 0.0;
    if (opacity > 1.0) opacity = 1.0;
    return (opacity * 255).round();
  }

  static ThemeData get artisanTheme {
    final baseColorScheme = ColorScheme.dark(
      primary: accentBlue,
      onPrimary: nearBlack, // Text/icons on primary color
      
      secondary: accentBlue, // Can be same as primary or a different accent
      onSecondary: nearBlack, // Text/icons on secondary color
      
      surface: surface,     // General surfaces
      onSurface: offWhite,    // Text/icons on general surfaces
      
      background: nearBlack,  // Overall app background
      onBackground: offWhite, // Text/icons on overall background
      
      error: errorColor,
      onError: onErrorColor,

      // M3 derived roles (Flutter will derive many, but we can specify some for consistency)
      surfaceTint: accentBlue, // Often used to tint surfaces that elevate
      surfaceVariant: surfaceContainer, // For less prominent surfaces
      onSurfaceVariant: mediumGrey,     // Text/icons on surfaceVariant
      outline: mediumGrey.withAlpha(_alphaFromOpacity(0.5)), // Borders
      outlineVariant: mediumGrey.withAlpha(_alphaFromOpacity(0.3)), // Subtle borders

      // Additional surface container roles for more nuanced layering
      // Flutter's ColorScheme.fromSeed generates these, but with .dark we can be explicit if desired
      // or let Material 3 derive them based on primary, surface etc.
      // For simplicity in .dark(), we'll primarily use our defined surface colors in component themes.
    );

    final artisanTextTheme = TextTheme(
      displayLarge: TextStyle(color: offWhite, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      displayMedium: TextStyle(color: offWhite, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.25),
      displaySmall: TextStyle(color: offWhite, fontSize: 24, fontWeight: FontWeight.bold),
      
      headlineLarge: TextStyle(color: offWhite, fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: offWhite, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: offWhite, fontSize: 18, fontWeight: FontWeight.w600),
      
      titleLarge: TextStyle(color: offWhite, fontSize: 20, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(color: offWhite, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
      titleSmall: TextStyle(color: offWhite, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      
      bodyLarge: TextStyle(color: offWhite, fontSize: 16, height: 1.5, letterSpacing: 0.5),
      bodyMedium: TextStyle(color: mediumGrey, fontSize: 14, height: 1.4, letterSpacing: 0.25),
      bodySmall: TextStyle(color: mediumGrey, fontSize: 12, height: 1.3, letterSpacing: 0.4),
      
      labelLarge: TextStyle(color: offWhite, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1), // For buttons
      labelMedium: TextStyle(color: offWhite, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: TextStyle(color: offWhite, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    ).apply( // Apply a base font family if desired
        // fontFamily: 'YourAppFont', // Example
        );

    return ThemeData(
      useMaterial3: true, 
      brightness: Brightness.dark,
      colorScheme: baseColorScheme,
      scaffoldBackgroundColor: baseColorScheme.background,
      primaryColor: baseColorScheme.primary, // Legacy, colorScheme.primary is preferred
      textTheme: artisanTextTheme,
      
      appBarTheme: AppBarTheme(
        backgroundColor: baseColorScheme.surface, // Can also use surfaceContainer for slight elevation feel
        elevation: 0, // Flat M3 style
        titleTextStyle: artisanTextTheme.titleLarge?.copyWith(color: baseColorScheme.onSurface),
        iconTheme: IconThemeData(color: baseColorScheme.onSurface),
        surfaceTintColor: Colors.transparent, // Prevents tinting on scroll with M3
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseColorScheme.primary,
          foregroundColor: baseColorScheme.onPrimary,
          textStyle: artisanTextTheme.labelLarge,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Increased padding for better tap targets
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // More rounded corners
          minimumSize: Size(64, 50), // Ensure decent height
          elevation: 2, // Subtle elevation
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: baseColorScheme.primary, // Text/icon color
          side: BorderSide(color: baseColorScheme.outline, width: 1.5), // Use outline color from scheme
          textStyle: artisanTextTheme.labelLarge,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: Size(64, 50),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer, // Use a distinct surface container color
        hintStyle: TextStyle(color: mediumGrey.withAlpha(_alphaFromOpacity(0.8))),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Cleaner look with fillColor
        ),
        enabledBorder: OutlineInputBorder( // Subtle border when enabled and not focused
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: baseColorScheme.outline.withAlpha(_alphaFromOpacity(0.5))),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: baseColorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: mediumGrey), // Label text before focus/input
        floatingLabelStyle: TextStyle(color: baseColorScheme.primary), // Label when focused or has input
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Balanced padding
        errorStyle: TextStyle(color: baseColorScheme.error),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: baseColorScheme.primary.withAlpha(_alphaFromOpacity(0.12)), 
        selectedColor: baseColorScheme.primary,
        labelStyle: TextStyle(color: baseColorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
        secondaryLabelStyle: TextStyle(color: baseColorScheme.onPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Increased padding
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none, // Or use baseColorScheme.outline for subtle border
        elevation: 0,
        selectedShadowColor: Colors.transparent,
      ),

      cardTheme: CardThemeData( // CORRECTED: Used CardThemeData
        elevation: 0, // M3 often uses tonal elevation or outlines
        color: surfaceContainer, // Use a defined surface container color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: baseColorScheme.outline.withAlpha(_alphaFromOpacity(0.7))), 
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Standard margin
      ),

      dialogTheme: DialogThemeData( // CORRECTED: Used DialogThemeData
        backgroundColor: surfaceContainerHigh, // Darker, distinct background for dialogs
        elevation: 3, // Standard M3 dialog elevation
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), // More rounded
        titleTextStyle: artisanTextTheme.headlineSmall?.copyWith(color: baseColorScheme.onSurface),
        contentTextStyle: artisanTextTheme.bodyLarge?.copyWith(color: baseColorScheme.onSurfaceVariant),
        actionsPadding: EdgeInsets.all(16.0),
      ),
      
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Slightly less rounded
        backgroundColor: surfaceContainerHighest, // Use a high emphasis surface
        contentTextStyle: TextStyle(color: baseColorScheme.onSurface),
        actionTextColor: baseColorScheme.primary,
        elevation: 4,
        width: 400, // Example for desktop, adjust as needed or remove for default width
      ),

      switchTheme: SwitchThemeData( // CORRECTED: Used WidgetStateProperty
        thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return baseColorScheme.primary; // Thumb color when selected
          }
          if (states.contains(WidgetState.disabled)) {
            return mediumGrey.withAlpha(_alphaFromOpacity(0.5));
          }
          return mediumGrey; // Thumb color when off
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return baseColorScheme.primary.withAlpha(_alphaFromOpacity(0.5));
          }
          if (states.contains(WidgetState.disabled)) {
            return nearBlack.withAlpha(_alphaFromOpacity(0.3));
          }
          return nearBlack.withAlpha(_alphaFromOpacity(0.5)); // Track color when off
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
           if (states.contains(WidgetState.selected)) {
            return Colors.transparent; // No outline when selected and track is colored
          }
          if (states.contains(WidgetState.disabled)) {
            return mediumGrey.withAlpha(_alphaFromOpacity(0.2));
          }
          return mediumGrey.withAlpha(_alphaFromOpacity(0.7)); // Outline color for the track when off
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)){
            return baseColorScheme.primary.withAlpha(_alphaFromOpacity(0.1));
          }
          return null;
        })
      ),
      
      dividerTheme: DividerThemeData( // Added DividerTheme
        color: baseColorScheme.outline.withAlpha(_alphaFromOpacity(0.5)),
        space: 1,
        thickness: 1,
      ),

      textSelectionTheme: TextSelectionThemeData( // Added TextSelectionTheme
        cursorColor: baseColorScheme.primary,
        selectionColor: baseColorScheme.primary.withAlpha(_alphaFromOpacity(0.4)),
        selectionHandleColor: baseColorScheme.primary,
      ),

      tooltipTheme: TooltipThemeData( // Added TooltipTheme
        preferBelow: false,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: artisanTextTheme.bodySmall?.copyWith(color: baseColorScheme.onInverseSurface), // Use onInverseSurface for tooltip text
        decoration: BoxDecoration(
          color: baseColorScheme.inverseSurface, // Use inverseSurface for tooltip background
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}