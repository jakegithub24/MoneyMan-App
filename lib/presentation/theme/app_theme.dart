import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Updated 7 colors from colors.txt
  static const Color backgroundColor = Color(0xFF131313); // #131313 Background
  static const Color cardBackgroundColor = Color(0xFF1F271C); // #1f271c Card Background
  static const Color incomeColor = Color(0xFF6C9C3A); // #6c9c3a Income
  static const Color expenseColor = Color(0xFFD62B2B); // #d62b2b Expense
  static const Color textColor = Color(0xFFEEE9D9); // #eee9d9 Text
  static const Color baseHighlightColor = Color(0xFFE7C14D); // #e7c14d Base Highlight
  static const Color popHighlightColor = Color(0xFFE67E22); // #E67E22 Pop Highlight

  // Backward compatibility alias for color fields
  static const Color primaryColor = baseHighlightColor;
  static const Color secondaryColor = popHighlightColor;
  static const Color surfaceColor = cardBackgroundColor;
  static const Color surfaceCardColor = cardBackgroundColor;
  static const Color incomeGreen = incomeColor;
  static const Color expenseRed = expenseColor;
  static const Color textPrimary = textColor;
  static const Color textSecondary = textColor;

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
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: baseHighlightColor,
      colorScheme: const ColorScheme.dark(
        primary: baseHighlightColor,
        secondary: popHighlightColor,
        surface: cardBackgroundColor,
        onSurface: textColor,
        error: expenseColor,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: textColor,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: textColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      cardTheme: CardThemeData(
        color: cardBackgroundColor,
        elevation: 2,
        shadowColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackgroundColor,
        hintStyle: TextStyle(color: textColor.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textColor.withValues(alpha: 0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: baseHighlightColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseHighlightColor,
          foregroundColor: backgroundColor,
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
        foregroundColor: backgroundColor,
        elevation: 6,
        shape: CircleBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
