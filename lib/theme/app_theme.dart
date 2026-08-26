import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.yellow,
      scaffoldBackgroundColor: Colors.yellow[200],
      cardColor: Colors.yellow,
      colorScheme: ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.amber.shade700,
        surface: Colors.yellow,
        onSurface: Colors.black87,
        surfaceContainerHighest: Colors.yellow[400]!,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.yellow[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.amber,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      colorScheme: const ColorScheme.dark(
        primary: Colors.amber,
        secondary: Colors.amberAccent,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
        surfaceContainerHighest: Color(0xFF2C2C2C),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.amber,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF242424),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
