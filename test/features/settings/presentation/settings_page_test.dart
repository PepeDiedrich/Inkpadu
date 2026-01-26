import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appwrite/enums.dart';

import 'package:ai_handwriting_app/features/settings/presentation/settings_page.dart';
import 'package:ai_handwriting_app/features/input/presentation/pointer_settings_page.dart';
import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

class MockAuthController extends Mock implements AuthController {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockAuthController mockAuthController;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() async {
    registerFallbackValue(OAuthProvider.github);
    registerFallbackValue(FakeRoute());
    await LocaleSettings.setLocale(AppLocale.en);
  });

  setUp(() {
    mockAuthController = MockAuthController();
    mockNavigatorObserver = MockNavigatorObserver();

    // Default stubs
    when(() => mockAuthController.status).thenReturn(AuthStatus.authenticated);
    when(() => mockAuthController.isLoggedIn).thenReturn(true);
    when(() => mockAuthController.logout()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() => TranslationProvider(
    child: AuthScope(
      controller: mockAuthController,
      child: EditorSettingsScope(
        settings: EditorSettings(),
        child: PointerSettingsScope(
          settings: PointerSettings(),
          child: MaterialApp(
            home: const SettingsPage(),
            navigatorObservers: [mockNavigatorObserver],
          ),
        ),
      ),
    ),
  );

  testWidgets('SettingsPage renders all sections', (tester) async {
    // Increase size to avoid overflow
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('General'), findsOneWidget);
    expect(find.text('Input'), findsOneWidget);
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Cloud & Sync'), findsOneWidget);

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Input devices'), findsOneWidget);
    expect(find.text('Note editor'), findsOneWidget);
    expect(find.text('Stroke widths'), findsOneWidget);
    expect(find.text('Palm rejection'), findsOneWidget);
    expect(find.text('AI Assistant Persona'), findsOneWidget);
    expect(find.text('Storage target'), findsOneWidget);
    expect(find.text('Encryption'), findsOneWidget);

    // Account section
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('Tapping Input devices navigates to PointerSettingsPage', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Input devices'));
    await tester.pumpAndSettle();

    // Verify a push happened
    verify(
      () => mockNavigatorObserver.didPush(any(), any()),
    ).called(greaterThan(1));
    // Verify PointerSettingsPage is present
    expect(find.byType(PointerSettingsPage), findsOneWidget);
  });

  testWidgets('Tapping Log out calls auth.logout', (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Log out'),
      500,
      scrollable: find.byType(Scrollable),
    );

    await tester.tap(find.text('Log out'));
    await tester.pump();

    verify(() => mockAuthController.logout()).called(1);
    expect(find.text('Logged out'), findsOneWidget);
  });
}
