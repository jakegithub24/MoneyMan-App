import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Theme Palette
  static const Color darkBackgroundColor = Color(0xFF131313); // #131313 Background
  static const Color darkCardBackgroundColor = Color(0xFF1F271C); // #1f271c Card Background
  static const Color darkTextColor = Color(0xFFEEE9D9); // #eee9d9 Subtle white text
  static const Color darkBorderColor = Color(0xFF2A3526);
  static const Color darkDividerColor = Color(0xFF131313);

  // Light Theme Palette
  // Subtle white for screen background (not stark #fff)
  static const Color lightBackgroundColor = Color(0xFFF6F8F6);
  // Pure white for cards
  static const Color lightCardBackgroundColor = Color(0xFFFFFFFF);
  // Dark text on white cards/screen
  static const Color lightTextColor = Color(0xFF131313);
  static const Color lightBorderColor = Color(0xFFE2E8F0);
  static const Color lightDividerColor = Color(0xFFEDF2F7);

  // Shared Brand & Financial Colors
  static const Color incomeColor = Color(0xFF6C9C3A); // #6c9c3a Income
  static const Color expenseColor = Color(0xFFD62B2B); // #d62b2b Expense
  static const Color baseHighlightColor = Color(0xFFE7C14D); // #e7c14d Base Highlight
  static const Color popHighlightColor = Color(0xFFE67E22); // #E67E22 Pop Highlight
  static const Color subtleWhite = Color(0xFFDDF2C9); // #DDF2C9 Subtle White

  // Dynamic Theme Mode State
  static ThemeMode currentThemeMode = ThemeMode.system;

  static bool isDark([BuildContext? context]) {
    if (context != null) {
      return Theme.of(context).brightness == Brightness.dark;
    }
    if (currentThemeMode == ThemeMode.dark) return true;
    if (currentThemeMode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  // Dynamic Getters
  static Color get backgroundColor => isDark() ? darkBackgroundColor : lightBackgroundColor;
  static Color get cardBackgroundColor => isDark() ? darkCardBackgroundColor : lightCardBackgroundColor;
  static Color get textColor => isDark() ? darkTextColor : lightTextColor;
  static Color get textSecondary => isDark() ? const Color(0xFFCCC7B8) : const Color(0xFF4A5568);
  static Color get borderColor => isDark() ? darkBorderColor : lightBorderColor;
  static Color get dividerColor => isDark() ? darkDividerColor : lightDividerColor;

  // Backward compatibility aliases
  static const Color primaryColor = baseHighlightColor;
  static const Color secondaryColor = popHighlightColor;
  static Color get surfaceColor => cardBackgroundColor;
  static Color get surfaceCardColor => cardBackgroundColor;
  static const Color incomeGreen = incomeColor;
  static const Color expenseRed = expenseColor;
  static Color get textPrimary => textColor;

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [baseHighlightColor, popHighlightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient balanceGradient = const LinearGradient(
    colors: [incomeColor, baseHighlightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      primaryColor: baseHighlightColor,
      colorScheme: const ColorScheme.dark(
        primary: baseHighlightColor,
        secondary: popHighlightColor,
        surface: darkCardBackgroundColor,
        onSurface: darkTextColor,
        error: expenseColor,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: darkTextColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: darkTextColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: darkTextColor,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: darkTextColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: darkTextColor),
      ),
      cardTheme: CardThemeData(
        color: darkCardBackgroundColor,
        elevation: 2,
        shadowColor: darkBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBackgroundColor,
        hintStyle: TextStyle(color: darkTextColor.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkTextColor.withValues(alpha: 0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: baseHighlightColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseHighlightColor,
          foregroundColor: darkBackgroundColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: baseHighlightColor,
        foregroundColor: darkBackgroundColor,
        elevation: 6,
        shape: CircleBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackgroundColor,
      primaryColor: baseHighlightColor,
      colorScheme: const ColorScheme.light(
        primary: baseHighlightColor,
        secondary: popHighlightColor,
        surface: lightCardBackgroundColor,
        onSurface: lightTextColor,
        error: expenseColor,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: lightTextColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: lightTextColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: lightTextColor,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: lightTextColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: lightTextColor),
      ),
      cardTheme: CardThemeData(
        color: lightCardBackgroundColor,
        elevation: 2,
        shadowColor: const Color(0x0F000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCardBackgroundColor,
        hintStyle: TextStyle(color: lightTextColor.withValues(alpha: 0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightTextColor.withValues(alpha: 0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: baseHighlightColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseHighlightColor,
          foregroundColor: darkBackgroundColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: baseHighlightColor,
        foregroundColor: darkBackgroundColor,
        elevation: 6,
        shape: CircleBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightCardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
