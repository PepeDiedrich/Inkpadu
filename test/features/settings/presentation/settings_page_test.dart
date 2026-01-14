import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_handwriting_app/features/settings/presentation/settings_page.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

class MockAuthController extends Mock implements AuthController {}

void main() {
  late MockAuthController mockAuthController;
  late PointerSettings pointerSettings;
  late EditorSettings editorSettings;

  setUp(() {
    mockAuthController = MockAuthController();
    when(() => mockAuthController.isLoggedIn).thenReturn(false);
    pointerSettings = PointerSettings();
    editorSettings = EditorSettings();
  });

  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  Future<void> pumpSettingsPage(WidgetTester tester) async {
    // Set a large enough screen to minimize scrolling issues,
    // but still test scrolling if needed.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    // Add tearDown to reset surface size
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TranslationProvider(
        child: AuthScope(
          controller: mockAuthController,
          child: PointerSettingsScope(
            settings: pointerSettings,
            child: EditorSettingsScope(
              settings: editorSettings,
              child: MaterialApp(
                home: const SettingsPage(),
                locale: AppLocale.en.flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SettingsPage', () {
    testWidgets('renders all sections and tiles', (WidgetTester tester) async {
      await pumpSettingsPage(tester);

      // Verify sections
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Input'), findsOneWidget);
      expect(find.text('AI Assistant'), findsOneWidget);
      expect(find.text('Cloud & Sync'), findsOneWidget);

      // Verify general tiles
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);

      // Verify input tiles
      expect(find.text('Input devices'), findsOneWidget);
      expect(find.text('Note editor'), findsOneWidget);
      expect(find.text('Stroke widths'), findsOneWidget);
      expect(find.text('Palm rejection'), findsOneWidget);

      // Verify AI tiles
      expect(find.text('AI Assistant Persona'), findsOneWidget);

      // Verify cloud tiles
      expect(find.text('Storage target'), findsOneWidget);
      expect(find.text('Encryption'), findsOneWidget);
    });

    testWidgets('navigates to PointerSettingsPage', (WidgetTester tester) async {
      await pumpSettingsPage(tester);

      final tileFinder = find.widgetWithText(InkWell, 'Input devices');
      await tester.ensureVisible(tileFinder);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      expect(find.text('Input devices'), findsAtLeastNWidgets(1)); // Title in AppBar and Body
      expect(find.text('Pen'), findsOneWidget);
    });

    testWidgets('navigates to EditorSettingsPage', (WidgetTester tester) async {
      await pumpSettingsPage(tester);

      final tileFinder = find.widgetWithText(InkWell, 'Note editor');
      await tester.ensureVisible(tileFinder);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      expect(find.text('Editor settings'), findsOneWidget);
      expect(find.text('Assist panel'), findsOneWidget);
    });

    testWidgets('navigates to AssistantPersonaSettingsPage', (WidgetTester tester) async {
      await pumpSettingsPage(tester);

      final tileFinder = find.widgetWithText(InkWell, 'AI Assistant Persona');
      await tester.ensureVisible(tileFinder);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      expect(find.text('AI Assistant Persona'), findsOneWidget);
      expect(find.text("Choose your AI assistant's style"), findsOneWidget);
    });

    testWidgets('shows logout section when logged in', (WidgetTester tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(true);
      when(() => mockAuthController.logout()).thenAnswer((_) async {});

      await pumpSettingsPage(tester);

      // Verify logout section
      final logoutTextFinder = find.text('Account');
      await tester.ensureVisible(logoutTextFinder);
      expect(logoutTextFinder, findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);

      // Tap logout
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      verify(() => mockAuthController.logout()).called(1);
      expect(find.text('Logged out'), findsOneWidget);
    });

    testWidgets('hides logout section when logged out', (WidgetTester tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(false);

      await pumpSettingsPage(tester);

      expect(find.text('Account'), findsNothing);
      expect(find.text('Log out'), findsNothing);
    });
  });
}
