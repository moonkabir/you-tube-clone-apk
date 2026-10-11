import 'package:flutter/material.dart';

/// Cheerful, high-contrast, toddler-safe color palette
class AppColors {
  // Primary Playful Colors
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color vibrantCoral = Color(0xFFFF5252);
  static const Color sunnyYellow = Color(0xFFFFD600);
  static const Color bubbleGumPink = Color(0xFFFF4081);
  static const Color mintGreen = Color(0xFF00E676);
  static const Color playfulPurple = Color(0xFF7C4DFF);
  static const Color skyCyan = Color(0xFF00B0FF);
  static const Color deepOrange = Color(0xFFFF6D00);

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color cardLight = Colors.white;
  static const Color surfaceMuted = Color(0xFFEFF2F8);

  // Text & Neutrals
  static const Color textDark = Color(0xFF212121);
  static const Color textMuted = Color(0xFF757575);
  static const Color textLight = Colors.white;

  // Lock State Colors
  static const Color lockActive = Color(0xFFFF1744);
  static const Color lockOverlay = Color(0x66000000);
  static const Color lockSuccess = Color(0xFF00E676);

  // Dynamic card accents for grid variation
  static const List<Color> cardAccents = [
    bubbleGumPink,
    primaryBlue,
    mintGreen,
    playfulPurple,
    deepOrange,
    skyCyan,
  ];

  static Color getAccent(int index) {
    return cardAccents[index % cardAccents.length];
  }
}
