import 'package:flutter/material.dart';
import 'landing_page.dart'; // Import Landing Page

void main() {
  runApp(MaterialApp(
    title: 'Preservando el Patrimonio de Yucatán',
    theme: ThemeData(
      primarySwatch: MaterialColor(
        0xFF45A186,
        {
          50: Color(0xFFE0F2EC),
          100: Color(0xFFB3DEC8),
          200: Color(0xFF80C9A2),
          300: Color(0xFF4DB47B),
          400: Color(0xFF26A25F),
          500: Color(0xFF45A186), // Primary color
          600: Color(0xFF409A7F),
          700: Color(0xFF388F74),
          800: Color(0xFF30856A),
          900: Color(0xFF217055),
        },
      ),
    ),
    home: LandingPage(),
  ));
}