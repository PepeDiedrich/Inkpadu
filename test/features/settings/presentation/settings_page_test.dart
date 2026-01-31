import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/settings/presentation/settings_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/auth_mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockAuthController mockAuthController;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
    registerAuthFallbackValues();
    registerFallbackValue(
      MaterialPageRoute<dynamic>(builder: (_) => const SizedBox()),
    );
  });

  setUp(() {
    mockAuthController = MockAuthController();
    mockNavigatorObserver = MockNavigatorObserver();

    // Default logged in for SettingsPage
    when(() => mockAuthController.isLoggedIn).thenReturn(true);
    when(() => mockAuthController.status).thenReturn(AuthStatus.authenticated);
    when(() => mockAuthController.logout()).thenAnswer((_) async {});
  });

  Future<void> pumpSettingsPage(WidgetTester tester) async {
    // Provide real settings instances as they are pure logic
    final pointerSettings = PointerSettings();
    final editorSettings = EditorSettings();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TranslationProvider(
        child: AuthScope(
          controller: mockAuthController,
          child: PointerSettingsScope(
            settings: pointerSettings,
            child: EditorSettingsScope(
              settings: editorSettings,
              child: MaterialApp(
                locale: LocaleSettings.currentLocale.flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                home: const SettingsPage(),
                navigatorObservers: [mockNavigatorObserver],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all sections correctly', (tester) async {
    await pumpSettingsPage(tester);

    expect(find.text('Settings'), findsOneWidget); // Title
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Input'), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text('AI Assistant'),
      500,
      scrollable: scrollable,
    );
    expect(find.text('AI Assistant'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cloud & Sync'),
      500,
      scrollable: scrollable,
    );
    expect(find.text('Cloud & Sync'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Account'),
      500,
      scrollable: scrollable,
    );
    expect(find.text('Account'), findsOneWidget); // Logout section
  });

  testWidgets('logout button works', (tester) async {
    await pumpSettingsPage(tester);

    // Scroll to bottom
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log out'));
    await tester.pump();

    verify(() => mockAuthController.logout()).called(1);
    expect(find.text('Logged out'), findsOneWidget); // Snackbar
  });

  testWidgets('navigates to Input Devices settings', (tester) async {
    await pumpSettingsPage(tester);

    await tester.tap(find.text('Input devices'));
    await tester.pumpAndSettle();

    verify(() => mockNavigatorObserver.didPush(any(), any())).called(greaterThan(0));

    // Verify we are on the PointerSettingsPage
    expect(find.text('Input devices'), findsNWidgets(2)); // Tile title and Page title
    expect(find.text('Pen'), findsOneWidget);
  });

  testWidgets('navigates to Note Editor settings', (tester) async {
    await pumpSettingsPage(tester);

    await tester.tap(find.text('Note editor'));
    await tester.pumpAndSettle();

    // EditorSettingsPage should be visible
    // We check for a text unique to that page
    expect(find.text('Editor settings'), findsOneWidget); // AppBar title
  });

  testWidgets('hides logout section when not logged in', (tester) async {
    when(() => mockAuthController.isLoggedIn).thenReturn(false);
    when(() => mockAuthController.status).thenReturn(AuthStatus.unauthenticated);

    await pumpSettingsPage(tester);

    expect(find.text('Account'), findsNothing);
    expect(find.text('Log out'), findsNothing);
  });
}
