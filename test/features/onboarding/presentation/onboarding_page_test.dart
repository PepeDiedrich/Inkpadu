import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/app/router/app_routes.dart';
import 'package:ai_handwriting_app/features/onboarding/presentation/onboarding_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:appwrite/enums.dart';
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

    // Default: not logged in
    when(() => mockAuthController.isLoggedIn).thenReturn(false);
    when(() => mockAuthController.status).thenReturn(AuthStatus.unauthenticated);

    // Stub logging logic
    when(
      () => mockAuthController.loginWithProvider(
        provider: any(named: 'provider'),
        scopes: any(named: 'scopes'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> pumpOnboardingPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TranslationProvider(
        child: AuthScope(
          controller: mockAuthController,
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            initialRoute: AppRoutes.onboarding,
            navigatorObservers: [mockNavigatorObserver],
            routes: {
              AppRoutes.onboarding: (_) => const OnboardingPage(),
              AppRoutes.shell: (_) => const Scaffold(body: Text('Shell')),
            },
          ),
        ),
      ),
    );
  }

  testWidgets('renders content correctly', (tester) async {
    await pumpOnboardingPage(tester);

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('Welcome to Inkpadu'), findsOneWidget);
    expect(find.textContaining('Log in with GitHub'), findsOneWidget);
    expect(find.textContaining('Log in with Google'), findsOneWidget);
  });

  testWidgets('login with GitHub calls auth controller', (tester) async {
    await pumpOnboardingPage(tester);

    await tester.tap(find.textContaining('Log in with GitHub'));
    await tester.pump();

    verify(
      () => mockAuthController.loginWithProvider(
        provider: OAuthProvider.github,
        scopes: any(named: 'scopes'),
      ),
    ).called(1);
  });

  testWidgets('login with Google calls auth controller', (tester) async {
    await pumpOnboardingPage(tester);

    await tester.tap(find.textContaining('Log in with Google'));
    await tester.pump();

    verify(
      () => mockAuthController.loginWithProvider(
        provider: OAuthProvider.google,
        scopes: any(named: 'scopes'),
      ),
    ).called(1);
  });

  testWidgets('navigates to shell on successful login', (tester) async {
    // Simulate successful login
    when(
      () => mockAuthController.loginWithProvider(
        provider: any(named: 'provider'),
        scopes: any(named: 'scopes'),
      ),
    ).thenAnswer((_) async {
       when(() => mockAuthController.status).thenReturn(AuthStatus.authenticated);
    });

    await pumpOnboardingPage(tester);

    await tester.tap(find.textContaining('Log in with GitHub'));
    await tester.pumpAndSettle();

    verify(() => mockNavigatorObserver.didReplace(
      newRoute: any(named: 'newRoute'),
      oldRoute: any(named: 'oldRoute'),
    )).called(1);

    expect(find.text('Shell'), findsOneWidget);
  });

  testWidgets('shows error on login failure', (tester) async {
    when(
      () => mockAuthController.loginWithProvider(
        provider: any(named: 'provider'),
        scopes: any(named: 'scopes'),
      ),
    ).thenThrow(Exception('Login failed'));

    await pumpOnboardingPage(tester);

    await tester.tap(find.textContaining('Log in with GitHub'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Login (GitHub) failed'), findsOneWidget);
  });
}
