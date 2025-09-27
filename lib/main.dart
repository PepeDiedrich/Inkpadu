import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/app/router/app_routes.dart';
import 'package:ai_handwriting_app/app/shell/presentation/app_shell.dart';
import 'package:ai_handwriting_app/app/theme/app_theme.dart';
import 'package:ai_handwriting_app/features/onboarding/presentation/onboarding_page.dart';

/// Entry point for the handwriting prototype application.
void main() => runApp(const InkpaduApp());

/// Root widget that wires up shared theme and navigation.
class InkpaduApp extends StatelessWidget {
  /// Creates a new [InkpaduApp] instance.
  const InkpaduApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Inkpadu',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    initialRoute: AppRoutes.onboarding,
    routes: {
      AppRoutes.shell: (context) => const AppShell(),
      AppRoutes.onboarding: (context) => const OnboardingPage(),
    },
  );
}
