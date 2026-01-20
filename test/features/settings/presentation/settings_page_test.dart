import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_persona.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/settings/presentation/settings_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthController extends Mock implements AuthController {}

class MockPointerSettings extends Mock implements PointerSettings {}

class MockEditorSettings extends Mock implements EditorSettings {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockAuthController mockAuthController;
  late MockPointerSettings mockPointerSettings;
  late MockEditorSettings mockEditorSettings;
  late MockNavigatorObserver mockObserver;

  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.de);
    registerFallbackValue(
      MaterialPageRoute<dynamic>(builder: (_) => const SizedBox()),
    );
  });

  setUp(() {
    mockAuthController = MockAuthController();
    mockPointerSettings = MockPointerSettings();
    mockEditorSettings = MockEditorSettings();
    mockObserver = MockNavigatorObserver();

    // Default Stubs
    when(() => mockAuthController.isLoggedIn).thenReturn(true);
    when(() => mockAuthController.logout()).thenAnswer((_) async {});

    when(() => mockPointerSettings.stylusLocked).thenReturn(false);
    when(() => mockPointerSettings.allowStylus).thenReturn(true);
    when(() => mockPointerSettings.allowTouch).thenReturn(true);
    when(() => mockPointerSettings.allowMouse).thenReturn(true);
    when(() => mockPointerSettings.autoLockOnStylus).thenReturn(true);

    when(
      () => mockEditorSettings.sidebarSide,
    ).thenReturn(EditorSidebarSide.right);
    when(() => mockEditorSettings.lineSimplifierEnabled).thenReturn(true);
    when(() => mockEditorSettings.lineSimplifierStrength).thenReturn(0.25);
    when(() => mockEditorSettings.lineSimplifierMinTolerance).thenReturn(0.3);
    when(() => mockEditorSettings.debugModeEnabled).thenReturn(false);
    when(
      () => mockEditorSettings.assistantPersonaType,
    ).thenReturn(AssistantPersonaType.praising);
    when(() => mockEditorSettings.customAssistantPrompt).thenReturn(null);
  });

  Future<void> pumpSettingsPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      TranslationProvider(
        child: AuthScope(
          controller: mockAuthController,
          child: PointerSettingsScope(
            settings: mockPointerSettings,
            child: EditorSettingsScope(
              settings: mockEditorSettings,
              child: MaterialApp(
                locale: LocaleSettings.currentLocale.flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                navigatorObservers: [mockObserver],
                home: const SettingsPage(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SettingsPage', () {
    testWidgets('renders all main sections', (tester) async {
      await pumpSettingsPage(tester);

      // Verify Sections
      expect(find.text('Einstellungen'), findsOneWidget);
      expect(find.text('Allgemein'), findsOneWidget);
      expect(find.text('Eingabe'), findsOneWidget);
      expect(find.text('KI-Assistent'), findsOneWidget);
      expect(find.text('Cloud & Synchronisation'), findsOneWidget);
      expect(find.text('Konto'), findsOneWidget);
    });

    testWidgets('renders all settings tiles', (tester) async {
      await pumpSettingsPage(tester);

      // Tiles
      expect(find.text('Design'), findsOneWidget);
      expect(find.text('Sprache'), findsOneWidget);
      expect(find.text('Eingabegeräte'), findsOneWidget);
      expect(find.text('Notiz-Editor'), findsOneWidget);
      expect(find.text('Stiftstärken'), findsOneWidget);
      expect(find.text('Handflächen-Erkennung'), findsOneWidget);
      expect(find.text('KI-Assistent Persona'), findsOneWidget);
      expect(find.text('Speicherziel'), findsOneWidget);
      expect(find.text('Verschlüsselung'), findsOneWidget);
    });

    testWidgets('navigates to PointerSettingsPage on tap', (tester) async {
      await pumpSettingsPage(tester);

      await tester.tap(find.text('Eingabegeräte'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
      // "Eingabegeräte" is used in the AppBar of PointerSettingsPage
      expect(find.text('Eingabegeräte'), findsNWidgets(2));
    });

    testWidgets('navigates to EditorSettingsPage on tap', (tester) async {
      await pumpSettingsPage(tester);

      await tester.tap(find.text('Notiz-Editor'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
      expect(find.text('Editor-Einstellungen'), findsOneWidget);
    });

    testWidgets('navigates to AssistantPersonaSettingsPage on tap', (
      tester,
    ) async {
      await pumpSettingsPage(tester);

      await tester.tap(find.text('KI-Assistent Persona'));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
      // Verify we are on the new page by checking the AppBar title specifically
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('KI-Assistent Persona'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows logout button when logged in', (tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(true);
      await pumpSettingsPage(tester);

      expect(find.text('Konto'), findsOneWidget);
      expect(find.text('Abmelden'), findsOneWidget);
    });

    testWidgets('hides logout button when not logged in', (tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(false);
      await pumpSettingsPage(tester);

      expect(find.text('Konto'), findsNothing);
      expect(find.text('Abmelden'), findsNothing);
    });

    testWidgets('calls logout when logout button is tapped', (tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(true);
      await pumpSettingsPage(tester);

      await tester.tap(find.text('Abmelden'));
      await tester.pump(); // Start animation/async work

      verify(() => mockAuthController.logout()).called(1);
      expect(find.text('Abgemeldet'), findsOneWidget);
    });
  });
}
