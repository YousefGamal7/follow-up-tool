import 'package:flutter/material.dart';

class ObsidianTheme {
  // Brand & Background
  static const Color background = Color(0xFF051424);
  
  // Surfaces
  static const Color surfaceRecessed = Color(0xFF010F1F);
  static const Color surfaceCard = Color(0xFF0D1C2D);
  static const Color surfaceHover = Color(0xFF132238);
  static const Color surfaceModal = Color(0xFF1B2D46);

  // Accents
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryHover = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryHover = Color(0xFF22D3EE);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFEF4444);
  static const Color warningBadgeBg = Color(0xFF7F1D1D);
  static const Color warningBadgeText = Color(0xFFFCA5A5);
  static const Color neutral = Color(0xFF64748B);

  // Borders
  static const Color borderBlue = Color(0x1F3B82F6); // rgba(59, 130, 246, 0.12)
  static const Color borderWhite = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Shared Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceCard,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderWhite),
  );

  static BoxDecoration cardHoverDecoration = BoxDecoration(
    color: surfaceHover,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderBlue.withOpacity(0.3)),
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 2,
      )
    ]
  );

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      fontFamily: 'Inter', // Defaulting to Inter if available, fallback to sans-serif
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surfaceCard,
        error: warning,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
        bodySmall: TextStyle(color: textMuted),
      ),
      dividerColor: borderWhite,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceRecessed,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderWhite),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderWhite),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
