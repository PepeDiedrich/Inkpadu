import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appwrite/enums.dart';

import 'package:ai_handwriting_app/features/onboarding/presentation/onboarding_page.dart';
import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/app/router/app_routes.dart';
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
    when(
      () => mockAuthController.status,
    ).thenReturn(AuthStatus.unauthenticated);
    when(() => mockAuthController.isLoggedIn).thenReturn(false);
  });

  Widget createWidgetUnderTest() => TranslationProvider(
    child: AuthScope(
      controller: mockAuthController,
      child: MaterialApp(
        initialRoute: AppRoutes.onboarding,
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          AppRoutes.onboarding: (_) => const OnboardingPage(),
          AppRoutes.shell: (_) => const Scaffold(body: Text('Shell')),
        },
      ),
    ),
  );

  testWidgets('OnboardingPage renders correct text and buttons', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Your digital notebook'), findsOneWidget);
    expect(find.text('Welcome to Inkpadu'), findsOneWidget);
    expect(find.text('Log in with GitHub'), findsOneWidget);
    expect(find.text('Log in with Google'), findsOneWidget);
  });

  testWidgets('Tapping GitHub login calls auth.loginWithProvider', (
    tester,
  ) async {
    when(
      () => mockAuthController.loginWithProvider(
        provider: any(named: 'provider'),
        scopes: any(named: 'scopes'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in with GitHub'));
    await tester.pump();

    verify(
      () => mockAuthController.loginWithProvider(
        provider: OAuthProvider.github,
        scopes: const ['user:email'],
      ),
    ).called(1);
  });

  testWidgets('Shows error message when login fails', (tester) async {
    when(
      () => mockAuthController.loginWithProvider(
        provider: any(named: 'provider'),
        scopes: any(named: 'scopes'),
      ),
    ).thenThrow(Exception('Auth failed'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in with GitHub'));
    await tester.pump(); // Start async op
    await tester.pump(); // Finish async op

    expect(find.text('Login (GitHub) failed'), findsOneWidget);
  });

  testWidgets('Navigates to Shell when authenticated', (tester) async {
    // We need to simulate the state change.
    // Since OnboardingPage checks `auth.status == AuthStatus.authenticated` *after* the await,
    // we can control the flow.

    // Initial state
    when(
      () => mockAuthController.status,
    ).thenReturn(AuthStatus.unauthenticated);

    when(
      () => mockAuthController.loginWithProvider(
        provider: any(named: 'provider'),
        scopes: any(named: 'scopes'),
      ),
    ).thenAnswer((_) async {
      // Simulate state change during the call
      when(
        () => mockAuthController.status,
      ).thenReturn(AuthStatus.authenticated);
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in with GitHub'));
    await tester.pumpAndSettle();

    verify(
      () => mockNavigatorObserver.didReplace(
        newRoute: any(named: 'newRoute'),
        oldRoute: any(named: 'oldRoute'),
      ),
    ).called(1);
    expect(find.text('Shell'), findsOneWidget);
  });
}
