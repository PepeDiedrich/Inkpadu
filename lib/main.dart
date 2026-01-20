import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workmanager/workmanager.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ai_handwriting_app/app/router/app_routes.dart';
import 'package:ai_handwriting_app/app/shell/presentation/app_shell.dart';
import 'package:ai_handwriting_app/app/theme/app_theme.dart';
import 'package:ai_handwriting_app/features/onboarding/presentation/onboarding_page.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_sync_service.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_auth.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_local_storage.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_notes_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/azure_assistant_api_service.dart';
import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/background/sync_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Entry point for the handwriting prototype application.
Future<void> main() async {
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize localization with device locale
  await LocaleSettings.useDeviceLocale();
  
  // Initialize pdfrx cache directory
  Pdfrx.getCacheDirectory = () async {
    final dir = await getApplicationCacheDirectory();
    return '${dir.path}/pdfrx_cache';
  };

  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  if (isMobile) {
    // initialize background dispatcher before runApp
    await Workmanager().initialize(callbackDispatcher);
    // register periodic task (every 15 minutes is minimum on Android)
    await Workmanager().registerPeriodicTask(
      'inkpadu_periodic_sync',
      backgroundSyncTask,
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  runApp(TranslationProvider(child: const InkpaduApp()));
}

/// Root widget that wires up shared theme and navigation.
class InkpaduApp extends StatefulWidget {
  /// Creates a new [InkpaduApp] instance.
  const InkpaduApp({super.key});

  @override
  State<InkpaduApp> createState() => _InkpaduAppState();
}

class _InkpaduAppState extends State<InkpaduApp> {
  late final AuthController _authController;
  late final InkNotesRepository _repository;
  late final InkNotesController _notesController;
  final bool _isDesktop = !kIsWeb &&
      (Platform.isLinux || Platform.isMacOS || Platform.isWindows);
  // Globaler PageStorageBucket für persistente Scroll-Positionen
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _authController.addListener(_onAuthChanged);
    _authController.initialize();

    final notesSyncService = InkNotesSyncService();
    final localStorage = InkNotesLocalStorage();
    _repository = InkNotesRepository(localStorage: localStorage, syncService: notesSyncService);
    final authBridge = AuthControllerInkNotesAuth(_authController);
    _notesController = InkNotesController(repository: _repository, auth: authBridge);

    if (_isDesktop) {
      _notesController.startForegroundSync();
    }
  }

  void _onAuthChanged() {
    setState(() {});
    // Clear cached AI token when user logs out to prevent token leakage
    if (_authController.status == AuthStatus.unauthenticated) {
      AzureAssistantApiService.clearCachedToken();
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthChanged);
    _notesController.dispose();
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pointerSettings = PointerSettings();
    final editorSettings = EditorSettings();

    // If user isn't authenticated (and no cached user), force onboarding/login.
    

    return AuthScope(
      controller: _authController,
      child: InkNotesScope(
        controller: _notesController,
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
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              // Globaler PageStorage-Bucket, damit Scrollpositionen
              // auch nach Schließen/erneutem Öffnen einer Route erhalten bleiben.
              builder: (context, child) => PageStorage(
                bucket: _pageStorageBucket,
                child: child!,
              ),
              // Decide home based on current auth state or whether the user has ever logged in.
              // This ensures onboarding is skipped after a successful login even if session
              // needs to be restored later.
              home: Builder(
                builder: (context) {
                  final shouldShowOnboarding = !_authController.isLoggedIn && !_authController.hasLoggedIn;
                  return shouldShowOnboarding ? const OnboardingPage() : const AppShell();
                },
              ),
              routes: {
                AppRoutes.onboarding: (context) => const OnboardingPage(),
              },
            ),
          ),
        ),
      ),
    );
  }
}
