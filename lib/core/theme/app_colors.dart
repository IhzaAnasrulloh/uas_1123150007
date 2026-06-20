import 'package:flutter/material.dart';

class AppColors {
  // Primary Gold/Maroon (gocap Theme)
  static const Color primary = Color(0xFFD4A574);
  static const Color primaryLight = Color(0xFFE8C9A3);
  static const Color primaryDark = Color(0xFF8B4513);
  static const Color primarySurface = Color(0xFFFEF5E7);
  static const Color primaryBorder = Color(0xFFDEB887);

  // Semantic
  static const Color green = Color(0xFF1F7F1B);
  static const Color greenSurface = Color(0xFFE8F8E8);
  static const Color amber = Color(0xFFC41E3A);
  static const Color amberSurface = Color(0xFFFCE4E6);
  static const Color red = Color(0xFFA41E34);
  static const Color redSurface = Color(0xFFFAEBED);
  static const Color violet = Color(0xFF8B5A3C);
  static const Color violetSurface = Color(0xFFF5EDE3);

  // Neutral
  static const Color ink = Color(0xFF0E1726);
  static const Color slate600 = Color(0xFF4B5E78);
  static const Color slate500 = Color(0xFF6B7A90);
  static const Color slate400 = Color(0xFF9DABBE);
  static const Color slate300 = Color(0xFFCBD2DD);
  static const Color line = Color(0xFFE8ECF2);
  static const Color line2 = Color(0xFFF3F5F8);
  static const Color bg = Color(0xFFF6F7F9);
  static const Color white = Color(0xFFFFFFFF);

  // Gradient - gocap Gold Theme
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
    colors: [primaryLight, primary, Color(0xFF704214)],
  );

  // Shadows
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0x52D4A574),
      blurRadius: 22,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [primarySurface, primary],
    'green': [greenSurface, green],
    'amber': [amberSurface, amber],
    'red': [redSurface, red],
    'violet': [violetSurface, violet],
    'slate': [bg, slate600],
    'gold': [primarySurface, primary],
    'islamic': [greenSurface, green],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['blue']!;
}
