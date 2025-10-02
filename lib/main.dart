import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ai_handwriting_app/app/router/app_routes.dart';
import 'package:ai_handwriting_app/app/shell/presentation/app_shell.dart';
import 'package:ai_handwriting_app/app/theme/app_theme.dart';
import 'package:ai_handwriting_app/features/onboarding/presentation/onboarding_page.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';

/// Entry point for the handwriting prototype application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const InkpaduApp());
}

/// Root widget that wires up shared theme and navigation.
class InkpaduApp extends StatelessWidget {
  /// Creates a new [InkpaduApp] instance.
  const InkpaduApp({super.key});

  @override
  Widget build(BuildContext context) {
    final notesController = InkNotesController();
    final pointerSettings = PointerSettings();
    final editorSettings = EditorSettings();
    final authController = AuthController()..initialize();
    return AuthScope(
      controller: authController,
      child: InkNotesScope(
      controller: notesController,
      child: PointerSettingsScope(
        settings: pointerSettings,
        child: EditorSettingsScope(
          settings: editorSettings,
          child: MaterialApp(
            title: 'Inkpadu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.light,
            initialRoute: AppRoutes.onboarding,
            routes: {
              AppRoutes.shell: (context) => const AppShell(),
              AppRoutes.onboarding: (context) => const OnboardingPage(),
            },
          ),
        ),
      ),
      ),
    );
  }
}
