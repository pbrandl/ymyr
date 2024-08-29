import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData generateTheme(Color seedColor) {
    return ThemeData(
      brightness: Brightness.dark, // Base the theme on a dark theme
      primaryColor: seedColor, // Use the seed color as the primary color
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark, // Ensure the color scheme is dark
      ),

      // High contrast text styles
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall: TextStyle(fontSize: 14.0, color: Colors.white),
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

      // Input decoration theme for text fields with high contrast
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: seedColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: seedColor, width: 2.0),
        ),
        labelStyle: TextStyle(color: Colors.white),
      ),

      // App bar theme with high contrast
      appBarTheme: AppBarTheme(
        color: seedColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Other customizable colors and themes
      scaffoldBackgroundColor: Colors.black, // Overall background color
      cardColor: Colors.grey[850], // Card color for dark theme
      dividerColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }
}
