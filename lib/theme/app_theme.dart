import 'package:flutter/material.dart';

class AppTheme {
  // Brand & Emergency Palette
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkCardBg = Color(0xFF1E293B); // Slate 800
  static const Color surfaceGlass = Color(0xFF334155); // Slate 700

  static const Color emergencyRed = Color(0xFFEF4444); // Crimson Alert Red
  static const Color emergencyRedGlow = Color(0xFFDC2626);
  static const Color amberWarning = Color(0xFFF59E0B); // Caution Amber
  static const Color armedGreen = Color(0xFF10B981); // Emerald Armed Green
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBackground,
      primaryColor: emergencyRed,
      colorScheme: const ColorScheme.dark(
        primary: emergencyRed,
        secondary: amberWarning,
        surface: darkCardBg,
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emergencyRed,
          foregroundColor: Colors.white,
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
