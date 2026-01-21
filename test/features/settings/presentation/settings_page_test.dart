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

  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  setUp(() {
    mockAuthController = MockAuthController();
    pointerSettings = PointerSettings();
    editorSettings = EditorSettings();
  });

  Future<void> pumpSettingsPage(WidgetTester tester) async {
    // Increase size to avoid overflow and ensure scrollability
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      TranslationProvider(
        child: MultiInheritedNotifier(
          authController: mockAuthController,
          pointerSettings: pointerSettings,
          editorSettings: editorSettings,
          child: const MaterialApp(home: SettingsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('SettingsPage renders all sections', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    await pumpSettingsPage(tester);

    // Verify sections using generated translations
    expect(find.text(t.settings.general), findsOneWidget);
    expect(find.text(t.settings.input), findsOneWidget);
    expect(find.text(t.ai.assistant), findsOneWidget);
    expect(find.text(t.settings.cloud), findsOneWidget);

    // Verify tiles
    expect(find.text(t.settings.theme), findsOneWidget);
    expect(find.text(t.settings.language), findsOneWidget);
    expect(find.text(t.settings.inputDevices), findsOneWidget);
    expect(find.text(t.settings.noteEditor), findsOneWidget);
    expect(find.text(t.ai.persona), findsOneWidget);
    expect(find.text(t.settings.storageTarget), findsOneWidget);
  });

  testWidgets('SettingsPage does not show logout when logged out', (
    tester,
  ) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    await pumpSettingsPage(tester);

    expect(find.text(t.settings.account), findsNothing);
    expect(find.text(t.auth.logout), findsNothing);
  });

  testWidgets('SettingsPage shows logout when logged in', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(true);

    await pumpSettingsPage(tester);

    // Scroll to bottom to ensure visibility
    await tester.scrollUntilVisible(
      find.text(t.auth.logout),
      500.0,
      scrollable: find.descendant(
        of: find.byKey(const PageStorageKey('settings_list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.settings.account), findsOneWidget);
    expect(find.text(t.auth.logout), findsOneWidget);
  });

  testWidgets('Tapping Logout triggers logout', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(true);
    when(() => mockAuthController.logout()).thenAnswer((_) async {});

    await pumpSettingsPage(tester);

    // Scroll to bottom
    final logoutFinder = find.text(t.auth.logout);
    await tester.scrollUntilVisible(
      logoutFinder,
      500.0,
      scrollable: find.descendant(
        of: find.byKey(const PageStorageKey('settings_list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(logoutFinder);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 500)); // Wait for snackbar

    verify(() => mockAuthController.logout()).called(1);
    expect(find.text(t.common.loggedOut), findsOneWidget);
  });

  testWidgets('Navigates to PointerSettingsPage', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    await pumpSettingsPage(tester);

    await tester.tap(find.text(t.settings.inputDevices));
    await tester.pumpAndSettle();

    // Verify we are on the new page
    expect(find.text(t.settings.automation), findsOneWidget);
  });

  testWidgets('Navigates to EditorSettingsPage', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    await pumpSettingsPage(tester);

    await tester.tap(find.text(t.settings.noteEditor));
    await tester.pumpAndSettle();

    expect(find.text(t.settings.editorSettings), findsOneWidget);
    expect(find.text(t.editor.assistPanel), findsOneWidget);
  });

  testWidgets('Navigates to AssistantPersonaSettingsPage', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    await pumpSettingsPage(tester);

    final personaFinder = find.text(t.ai.persona);
    await tester.scrollUntilVisible(
      personaFinder,
      500.0,
      scrollable: find.descendant(
        of: find.byKey(const PageStorageKey('settings_list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(personaFinder);
    await tester.pumpAndSettle();

    expect(find.text(t.editor.aiPersona), findsOneWidget);
    expect(find.text(t.editor.choosePersonaStyle), findsOneWidget);
  });
}

// Helper widget to provide multiple inherited notifiers
class MultiInheritedNotifier extends StatelessWidget {
  final Widget child;
  final AuthController authController;
  final PointerSettings pointerSettings;
  final EditorSettings editorSettings;

  const MultiInheritedNotifier({
    super.key,
    required this.child,
    required this.authController,
    required this.pointerSettings,
    required this.editorSettings,
  });

  @override
  Widget build(BuildContext context) => AuthScope(
    controller: authController,
    child: PointerSettingsScope(
      settings: pointerSettings,
      child: EditorSettingsScope(settings: editorSettings, child: child),
    ),
  );
}
