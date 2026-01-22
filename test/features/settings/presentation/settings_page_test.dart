import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/settings/presentation/settings_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthController extends Mock implements AuthController {}

void main() {
  late MockAuthController mockAuthController;
  late PointerSettings pointerSettings;
  late EditorSettings editorSettings;

  setUpAll(() async {
    await LocaleSettings.setLocale(AppLocale.en);
  });

  setUp(() {
    mockAuthController = MockAuthController();
    pointerSettings = PointerSettings();
    editorSettings = EditorSettings();
  });

  group('SettingsPage', () {
    testWidgets('renders all sections correctly', (tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(false);
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _createWidgetUnderTest(
          mockAuthController,
          pointerSettings,
          editorSettings,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Input'), findsOneWidget);
      expect(find.text('AI Assistant'), findsOneWidget);
      expect(find.text('Cloud & Sync'), findsOneWidget);

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Input devices'), findsOneWidget);
      expect(find.text('Note editor'), findsOneWidget);
      expect(find.text('AI Assistant Persona'), findsOneWidget);
      expect(find.text('Storage target'), findsOneWidget);
      expect(find.text('Encryption'), findsOneWidget);
    });

    testWidgets('renders logout section when logged in', (tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(true);
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _createWidgetUnderTest(
          mockAuthController,
          pointerSettings,
          editorSettings,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('does not render logout section when logged out', (
      tester,
    ) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(false);
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _createWidgetUnderTest(
          mockAuthController,
          pointerSettings,
          editorSettings,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsNothing);
      expect(find.text('Log out'), findsNothing);
    });

    testWidgets('calls logout when logout button is tapped', (tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(true);
      when(() => mockAuthController.logout()).thenAnswer((_) async {});
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _createWidgetUnderTest(
          mockAuthController,
          pointerSettings,
          editorSettings,
        ),
      );
      await tester.pumpAndSettle();

      // Ensure visible
      await tester.scrollUntilVisible(find.text('Log out'), 500);
      await tester.tap(find.text('Log out'));
      await tester.pump();

      verify(() => mockAuthController.logout()).called(1);
      expect(find.text('Logged out'), findsOneWidget);
    });

    testWidgets('navigates to Input Devices settings', (tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(false);
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _createWidgetUnderTest(
          mockAuthController,
          pointerSettings,
          editorSettings,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Input devices'));
      await tester.pumpAndSettle();

      // Assuming PointerSettingsPage doesn't have "AI Assistant" text
      expect(find.text('AI Assistant'), findsNothing);
    });

    testWidgets('navigates to Note Editor settings', (tester) async {
      when(() => mockAuthController.isLoggedIn).thenReturn(false);
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _createWidgetUnderTest(
          mockAuthController,
          pointerSettings,
          editorSettings,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Note editor'));
      await tester.pumpAndSettle();

      // Editor settings page has "Assist panel" text
      expect(find.text('Assist panel'), findsOneWidget);
    });
  });
}

Widget _createWidgetUnderTest(
  MockAuthController mockAuthController,
  PointerSettings pointerSettings,
  EditorSettings editorSettings,
) => TranslationProvider(
  child: AuthScope(
    controller: mockAuthController,
    child: PointerSettingsScope(
      settings: pointerSettings,
      child: EditorSettingsScope(
        settings: editorSettings,
        child: const MaterialApp(home: SettingsPage()),
      ),
    ),
  ),
);
