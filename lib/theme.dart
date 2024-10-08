import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData generateTheme(Color seedColor) {
    return ThemeData(
      brightness: Brightness.light, // Base the theme on a dark theme
      primaryColor: seedColor, // Use the seed color as the primary color
      canvasColor: const Color.fromARGB(255, 194, 186, 231),
      cardColor: const Color.fromARGB(255, 241, 158, 220),
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light, // Ensure the color scheme is dark
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 194, 186, 231),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 194, 186, 231),
      ),

      // High contrast text styles
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 14.0),
      ),

      // Button theme with high contrast
      buttonTheme: ButtonThemeData(
        buttonColor: seedColor, // Button background color based on seed color
        textTheme:
            ButtonTextTheme.primary, // Button text color will be primary color
      ),

      // Elevated button style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor, // Button background color
          foregroundColor: Colors.black, // Button text color
        ),
      ),
    );
  }
}
