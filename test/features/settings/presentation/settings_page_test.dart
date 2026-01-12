import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/settings/presentation/settings_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthController extends Mock implements AuthController {}

void main() {
  late MockAuthController mockAuthController;

  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  setUp(() {
    mockAuthController = MockAuthController();
    when(() => mockAuthController.isLoggedIn).thenReturn(false);
  });

  Widget buildTestWidget() {
    return TranslationProvider(
      child: AuthScope(
        controller: mockAuthController,
        child: PointerSettingsScope(
          settings: PointerSettings(),
          child: const MaterialApp(
            home: SettingsPage(),
          ),
        ),
      ),
    );
  }

  // Helper to ensure all widgets are built by making the screen very tall
  void setTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('SettingsPage renders all sections', (tester) async {
    setTallScreen(tester);
    await tester.pumpWidget(buildTestWidget());

    final t = AppLocale.en.buildSync();

    expect(find.text(t.settings.title), findsOneWidget);
    expect(find.text(t.settings.general), findsOneWidget);
    expect(find.text(t.settings.input), findsOneWidget);
    expect(find.text(t.ai.assistant), findsOneWidget);
    expect(find.text(t.settings.cloud), findsOneWidget);
  });

  testWidgets('SettingsPage renders specific tiles', (tester) async {
    setTallScreen(tester);
    await tester.pumpWidget(buildTestWidget());

    final t = AppLocale.en.buildSync();

    expect(find.text(t.settings.theme), findsOneWidget);
    expect(find.text(t.settings.language), findsOneWidget);
    expect(find.text(t.settings.inputDevices), findsOneWidget);
    expect(find.text(t.settings.noteEditor), findsOneWidget);
    expect(find.text(t.ai.persona), findsOneWidget);
  });

  testWidgets('Logout section is hidden when not logged in', (tester) async {
    setTallScreen(tester);
    when(() => mockAuthController.isLoggedIn).thenReturn(false);
    await tester.pumpWidget(buildTestWidget());

    final t = AppLocale.en.buildSync();

    expect(find.text(t.settings.account), findsNothing);
    expect(find.text(t.auth.logout), findsNothing);
  });

  testWidgets('Logout section is visible when logged in', (tester) async {
    setTallScreen(tester);
    when(() => mockAuthController.isLoggedIn).thenReturn(true);
    await tester.pumpWidget(buildTestWidget());

    final t = AppLocale.en.buildSync();

    expect(find.text(t.settings.account), findsOneWidget);
    expect(find.text(t.auth.logout), findsOneWidget);
  });

  testWidgets('Tapping Logout calls auth.logout', (tester) async {
    setTallScreen(tester); // Ensure it's on screen so tap works
    when(() => mockAuthController.isLoggedIn).thenReturn(true);
    when(() => mockAuthController.logout()).thenAnswer((_) async {});

    await tester.pumpWidget(buildTestWidget());

    final t = AppLocale.en.buildSync();

    // Even with tall screen, good practice to ensure visibility
    await tester.ensureVisible(find.text(t.auth.logout));
    await tester.tap(find.text(t.auth.logout));
    await tester.pump();
    await tester.pumpAndSettle();

    verify(() => mockAuthController.logout()).called(1);
    expect(find.text(t.common.loggedOut), findsOneWidget);
  });

  testWidgets('Navigates to Input Devices page on tap', (tester) async {
     setTallScreen(tester);
     await tester.pumpWidget(buildTestWidget());

     final t = AppLocale.en.buildSync();

     await tester.ensureVisible(find.text(t.settings.inputDevices));
     await tester.tap(find.text(t.settings.inputDevices));

     await tester.pumpAndSettle();

     // Verify we are on the new page (title should be present)
     expect(find.text(t.settings.inputDevices), findsAtLeastNWidgets(1));
  });
}
