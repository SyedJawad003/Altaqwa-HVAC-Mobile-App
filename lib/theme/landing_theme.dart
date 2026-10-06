import 'package:flutter/material.dart';

/// Design tokens and typography for AL TAQWA Cooling System landing website.
class LandingTheme {
  // Brand Blues
  static const Color navyDark = Color(0xFF040E22);
  static const Color navyDeep = Color(0xFF061A3D);
  static const Color navyMedium = Color(0xFF0B2B63);
  static const Color blueRoyal = Color(0xFF0B3A8C);
  static const Color blueAccent = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFF4F8FE0);
  static const Color blueIce = Color(0xFFE8F1FC);
  static const Color blueSoftBg = Color(0xFFF2F7FD);

  // Brand Gold Accents (Subtle, Metallic)
  static const Color goldDark = Color(0xFFB38634);
  static const Color gold = Color(0xFFC9A24A);
  static const Color goldLight = Color(0xFFE8CF8A);
  static const Color goldSoft = Color(0xFFFAF3E3);

  // Neutrals (NO RED)
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceOffWhite = Color(0xFFF8FAFC);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate900 = Color(0xFF0F172A);

  // Status Colors (Safe, UAE HVAC palette: blues, teals, golds, ambers - NO RED)
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFC9A24A);
  static const Color statusActive = Color(0xFF38BDF8);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF030D1E),
      Color(0xFF061A3D),
      Color(0xFF0B3A8C),
      Color(0xFF114299),
    ],
    stops: [0.0, 0.35, 0.75, 1.0],
  );

  static const LinearGradient blueSectionGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF061A3D),
      Color(0xFF0B2B63),
      Color(0xFF061A3D),
    ],
  );

  static const LinearGradient cardBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B2B63),
      Color(0xFF061A3D),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8CF8A),
      Color(0xFFC9A24A),
      Color(0xFFB38634),
    ],
  );

  static const LinearGradient goldTextGradient = LinearGradient(
    colors: [
      Color(0xFFFFF2D1),
      Color(0xFFE8CF8A),
      Color(0xFFC9A24A),
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x2EFFFFFF),
      Color(0x0FFFFFFF),
    ],
  );

  // Common Shadows
  static const List<BoxShadow> softCardShadow = [
    BoxShadow(
      color: Color(0x0C0B3A8C),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x08061A3D),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> goldGlowShadow = [
    BoxShadow(
      color: Color(0x38C9A24A),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> blueGlowShadow = [
    BoxShadow(
      color: Color(0x400B3A8C),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> phoneShadow = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 40,
      spreadRadius: -4,
      offset: Offset(0, 24),
    ),
    BoxShadow(
      color: Color(0x264F8FE0),
      blurRadius: 20,
      offset: Offset(0, 0),
    ),
  ];
}
