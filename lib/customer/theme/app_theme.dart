import 'package:flutter/material.dart';

const navy = Color(0xFF0A192F);
const navyDeep = Color(0xFF020C1B);
const gold = Color(0xFFD4AF37);
const goldLight = Color(0xFFE5C158);
const steel = Color(0xFFA0AEC0);

LinearGradient get navyGradient => const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [navy, Color(0xFF071426), navyDeep],
);

BoxDecoration get glassDecoration => BoxDecoration(
  color: Colors.white.withValues(alpha: 0.04),
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: gold.withValues(alpha: 0.3)),
);

ThemeData get alTaqwaTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: navy,
  colorScheme: const ColorScheme.dark(
    primary: gold,
    onPrimary: navy,
    secondary: goldLight,
    surface: navy,
    onSurface: Colors.white,
  ),
  fontFamily: 'Georgia',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.05),
    labelStyle: const TextStyle(color: steel),
    hintStyle: const TextStyle(color: steel),
    prefixIconColor: gold,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.white24),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.white24),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: gold, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: gold,
      foregroundColor: navy,
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      shape: const StadiumBorder(),
      elevation: 8,
      shadowColor: gold,
    ),
  ),
);
