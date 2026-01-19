import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_handwriting_app/features/settings/presentation/settings_page.dart';
import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:ai_handwriting_app/features/input/presentation/pointer_settings_page.dart';
import 'package:ai_handwriting_app/features/editor/presentation/editor_settings_page.dart';
import 'package:ai_handwriting_app/features/editor/presentation/assistant_persona_settings_page.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_persona.dart';

class MockAuthController extends Mock implements AuthController {}

class MockEditorSettings extends Mock implements EditorSettings {}

class MockPointerSettings extends Mock implements PointerSettings {}

void main() {
  late MockAuthController mockAuthController;
  late MockEditorSettings mockEditorSettings;
  late MockPointerSettings mockPointerSettings;

  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  setUp(() {
    mockAuthController = MockAuthController();
    mockEditorSettings = MockEditorSettings();
    mockPointerSettings = MockPointerSettings();

    // Default stubs to prevent crashes in child pages
    when(() => mockEditorSettings.sidebarSide).thenReturn(EditorSidebarSide.right);
    when(() => mockEditorSettings.lineSimplifierEnabled).thenReturn(true);
    when(() => mockEditorSettings.lineSimplifierStrength).thenReturn(0.25);
    when(() => mockEditorSettings.lineSimplifierMinTolerance).thenReturn(0.3);
    when(() => mockEditorSettings.debugModeEnabled).thenReturn(false);
    when(() => mockEditorSettings.assistantPersonaType).thenReturn(AssistantPersonaType.praising);
    when(() => mockEditorSettings.customAssistantPrompt).thenReturn(null);

    when(() => mockPointerSettings.allowStylus).thenReturn(true);
    when(() => mockPointerSettings.allowTouch).thenReturn(true);
    when(() => mockPointerSettings.allowMouse).thenReturn(true);
    when(() => mockPointerSettings.autoLockOnStylus).thenReturn(true);
    when(() => mockPointerSettings.stylusLocked).thenReturn(false);
  });

  Widget createWidgetUnderTest() => TranslationProvider(
    child: AuthScope(
      controller: mockAuthController,
      child: EditorSettingsScope(
        settings: mockEditorSettings,
        child: PointerSettingsScope(
          settings: mockPointerSettings,
          child: const MaterialApp(home: SettingsPage()),
        ),
      ),
    ),
  );

  testWidgets('SettingsPage renders all sections and tiles', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    // Increase screen size to see more items without scrolling
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify sections
    expect(find.text(t.settings.general), findsOneWidget);
    expect(find.text(t.settings.input), findsOneWidget);
    expect(find.text(t.ai.assistant), findsOneWidget);
    expect(find.text(t.settings.cloud), findsOneWidget);

    // Verify tiles presence (General)
    expect(find.text(t.settings.theme), findsOneWidget);
    expect(find.text(t.settings.language), findsOneWidget);

    // Verify tiles presence (Input)
    expect(find.text(t.settings.inputDevices), findsOneWidget);
    expect(find.text(t.settings.noteEditor), findsOneWidget);
    expect(find.text(t.settings.strokeWidths), findsOneWidget);
    expect(find.text(t.settings.palmRejection), findsOneWidget);

    // Verify tiles presence (AI)
    expect(find.text(t.ai.persona), findsOneWidget);

    // Verify tiles presence (Cloud)
    expect(find.text(t.settings.storageTarget), findsOneWidget);
    expect(find.text(t.settings.encryption), findsOneWidget);
  });

  testWidgets('Navigates to PointerSettingsPage when Input Devices is tapped', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final finder = find.text(t.settings.inputDevices);
    await tester.scrollUntilVisible(finder, 500.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(find.byType(PointerSettingsPage), findsOneWidget);
  });

  testWidgets('Navigates to EditorSettingsPage when Note Editor is tapped', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final finder = find.text(t.settings.noteEditor);
    await tester.scrollUntilVisible(finder, 500.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(find.byType(EditorSettingsPage), findsOneWidget);
  });

  testWidgets('Navigates to AssistantPersonaSettingsPage when Persona is tapped', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final finder = find.text(t.ai.persona);
    // Ensure we scroll to it
    await tester.scrollUntilVisible(finder, 500.0, scrollable: find.byType(Scrollable).first);

    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(find.byType(AssistantPersonaSettingsPage), findsOneWidget);
  });

  testWidgets('Logout section is hidden when not logged in', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text(t.settings.account), findsNothing);
    expect(find.text(t.auth.logout), findsNothing);
  });

  testWidgets('Logout section is visible when logged in', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(true);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final logoutFinder = find.text(t.auth.logout);
    await tester.scrollUntilVisible(logoutFinder, 500.0, scrollable: find.byType(Scrollable).first);

    expect(find.text(t.settings.account), findsOneWidget);
    expect(logoutFinder, findsOneWidget);
  });

  testWidgets('Tapping Logout calls auth.logout and shows SnackBar', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(true);
    when(() => mockAuthController.logout()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final logoutFinder = find.text(t.auth.logout);

    await tester.scrollUntilVisible(logoutFinder, 500.0, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    await tester.tap(logoutFinder);
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 100)); // Wait a bit for snackbar animation start

    verify(() => mockAuthController.logout()).called(1);
    expect(find.text(t.common.loggedOut), findsOneWidget);

    // Pump and settle to finish animations
    await tester.pumpAndSettle();
  });
}
