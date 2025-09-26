import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/app/theme/app_colors.dart';

/// Provides themed configurations for the Inkpadu application.
class AppTheme {
  /// Builds the light theme styled according to the brand palette.
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primaryAccent)
        .copyWith(
          primary: AppColors.primaryAccent,
          secondary: AppColors.secondaryAccent,
          surface: AppColors.lightBackground,
          onSurface: AppColors.darkText,
          onPrimary: AppColors.darkText,
          onSecondary: AppColors.darkText,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
    );

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.darkText,
        centerTitle: false,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(color: AppColors.darkText),
        backgroundColor: AppColors.primaryAccent,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.darkText,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        indicatorColor: AppColors.primaryAccent.withValues(alpha: 0.2),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  /// Builds the dark theme counterpart scoped to the brand palette.
  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryAccent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primaryAccent,
          secondary: AppColors.secondaryAccent,
          surface: AppColors.darkBackground,
          onSurface: AppColors.lightText,
          onPrimary: AppColors.darkText,
          onSecondary: AppColors.darkText,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
    );

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.lightText,
        centerTitle: false,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.lightText,
        displayColor: AppColors.lightText,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(color: AppColors.darkText),
        backgroundColor: AppColors.primaryAccent,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: const Color(0xFF23354A),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.darkText,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        indicatorColor: AppColors.primaryAccent.withValues(alpha: 0.3),
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
