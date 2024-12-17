import 'package:flutter/material.dart';
ThemeData darkmode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade800, // Darker surface color
    primary: Colors.black,         // Main background or scaffold color
    secondary: Colors.grey.shade700, // For secondary UI components
    tertiary: Colors.white,        // Accent or highlight color
    inversePrimary: Colors.grey.shade200, // Inverse of primary
  ),
);