import 'package:flutter/material.dart';

/// Defines the primary color palette for the application.
class AppColors {
  /// Very dark blue background used in dark mode.
  static const Color darkBackground = Color(0xFF1A2A3A);

  /// Cool gray background used in light mode (not warm gray).
  static const Color lightBackground = Color(0xFFF5F7FA);

  /// Pure white surface for note cards.
  static const Color surface = Color(0xFFFFFFFF);

  /// Text color for dark backgrounds.
  static const Color lightText = Color(0xFFE0E0E0);

  /// Text color for light backgrounds.
  static const Color darkText = Color(0xFF333333);

  /// Dark ink blue for text/icons on primary color (high contrast).
  /// CRITICAL: Use this for any text or icon on primaryAccent background.
  static const Color onPrimary = Color(0xFF011F4B);

  /// Intense sky blue primary accent color (from logo gradient).
  static const Color primaryAccent = Color(0xFF38BDF8);

  /// Very light sky blue for hover states (10% opacity feel).
  static const Color primaryHover = Color(0xFFE3F6FD);

  /// Soft indigo secondary accent color (from logo gradient).
  static const Color secondaryAccent = Color(0xFF818CF8);

  /// Cyan gradient start from logo.
  static const Color accentGradientStart = Color(0xFF00F2FE);
}
