import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color constants
  static const Color primaryColor = Color(0xFF3F51B5);      // Indigo
  static const Color secondaryColor = Color(0xFF536DFE);    // Indigo accent
  static const Color accentColor = Color(0xFFFF4081);       // Pink accent
  static const Color backgroundColor = Color(0xFFF5F5F5);   // Light grey
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFD50000);        // Red
  static const Color successColor = Color(0xFF00C853);      // Green
  static const Color warningColor = Color(0xFFFFD600);      // Yellow
  static const Color textDarkColor = Color(0xFF212121);     // Almost black
  static const Color textLightColor = Color(0xFF757575);    // Medium grey

  // Gradient backgrounds
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3949AB),  // Indigo 700
      Color(0xFF1A237E),  // Indigo 900
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8EAF6),  // Indigo 50
      Color(0xFFF5F5F5),  // Grey 100
    ],
  );

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration slowAnimation = Duration(milliseconds: 800);

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textDarkColor,
    letterSpacing: 0.5,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryColor,
    letterSpacing: 0.3,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textDarkColor,
    letterSpacing: 0.2,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textLightColor,
    letterSpacing: 0.1,
  );

  // Input decoration
  static InputDecoration inputDecoration({
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryColor) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Button styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Get complete theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: secondaryButtonStyle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: headingStyle,
        titleLarge: subheadingStyle,
        bodyLarge: bodyStyle,
        bodySmall: captionStyle,
      ),
      useMaterial3: true,
    );
  }
}