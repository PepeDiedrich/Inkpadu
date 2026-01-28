import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/editor/presentation/assistant_persona_settings_page.dart';
import 'package:ai_handwriting_app/features/editor/presentation/editor_settings_page.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/input/presentation/pointer_settings_page.dart';
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

  Widget createWidgetUnderTest({bool isLoggedIn = true}) {
    when(() => mockAuthController.isLoggedIn).thenReturn(isLoggedIn);

    return TranslationProvider(
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
  }

  testWidgets('SettingsPage renders all sections and tiles', (tester) async {
    // Increase size to avoid RenderFlex overflow on small test screens
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());

    // Verify AppBar
    expect(find.text('Settings'), findsOneWidget);

    // Verify Sections
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Input'), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Cloud & Sync'), findsOneWidget);

    // Verify Tiles (Sampling)
    expect(find.text('Input devices'), findsOneWidget);
    expect(find.text('Note editor'), findsOneWidget);
    expect(find.text('AI Assistant Persona'), findsOneWidget);
    expect(find.text('Storage target'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('SettingsPage navigates to Input Devices', (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Input devices'));
    await tester.pumpAndSettle();

    // Verify PointerSettingsPage is shown
    expect(find.byType(PointerSettingsPage), findsOneWidget);
    // AppBar title should be 'Input devices'
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Input devices'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('SettingsPage navigates to Editor Settings', (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Note editor'));
    await tester.pumpAndSettle();

    // Verify EditorSettingsPage is shown
    expect(find.byType(EditorSettingsPage), findsOneWidget);
    expect(find.text('Editor settings'), findsOneWidget);
  });

  testWidgets('SettingsPage navigates to Assistant Persona Settings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('AI Assistant Persona'));
    await tester.pumpAndSettle();

    // Verify AssistantPersonaSettingsPage is shown
    expect(find.byType(AssistantPersonaSettingsPage), findsOneWidget);
    // AppBar title
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('AI Assistant Persona'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('SettingsPage shows logout button when logged in', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.resetPhysicalSize);

    // Setup mock for logout
    when(() => mockAuthController.logout()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    // Verify Logout button exists
    final logoutFinder = find.text('Log out');
    expect(logoutFinder, findsOneWidget);

    // Tap logout
    await tester.tap(logoutFinder);
    await tester.pumpAndSettle();

    // Verify logout called
    verify(() => mockAuthController.logout()).called(1);

    // Verify Snackbar
    expect(find.text('Logged out'), findsOneWidget);
  });

  testWidgets('SettingsPage hides logout button when logged out', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest(isLoggedIn: false));

    // Verify Logout button does not exist
    expect(find.text('Log out'), findsNothing);
  });
}
