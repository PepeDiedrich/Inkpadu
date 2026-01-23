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

class MockAuthController extends Mock implements AuthController {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockAuthController mockAuth;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.de);
    registerFallbackValue(OAuthProvider.github);
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockAuth = MockAuthController();
    mockNavigatorObserver = MockNavigatorObserver();

    // Default stubs
    when(() => mockAuth.status).thenReturn(AuthStatus.unauthenticated);
    when(() => mockAuth.isLoggedIn).thenReturn(false);
    when(() => mockAuth.addListener(any())).thenReturn(null);
    when(() => mockAuth.removeListener(any())).thenReturn(null);
  });

  Widget buildSubject() => TranslationProvider(
        child: AuthScope(
          controller: mockAuth,
          child: MaterialApp(
            locale: LocaleSettings.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            navigatorObservers: [mockNavigatorObserver],
            routes: {
              AppRoutes.onboarding: (_) => const OnboardingPage(),
              AppRoutes.shell: (_) => const Scaffold(body: Text('Shell Page')),
            },
            initialRoute: AppRoutes.onboarding,
          ),
        ),
      );

  group('OnboardingPage', () {
    testWidgets('renders welcome text and buttons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Willkommen bei Inkpadu'), findsOneWidget);
      expect(find.text('Dein digitales Notizbuch'), findsOneWidget);
      expect(find.text('Mit GitHub anmelden'), findsOneWidget);
      expect(find.text('Mit Google anmelden'), findsOneWidget);
    });

    testWidgets('calls loginWithProvider (GitHub) and navigates on success', (
      tester,
    ) async {
      when(
        () => mockAuth.loginWithProvider(
          provider: any(named: 'provider'),
          scopes: any(named: 'scopes'),
        ),
      ).thenAnswer((_) async {
        // Update status to authenticated immediately to simulate success
        when(() => mockAuth.status).thenReturn(AuthStatus.authenticated);
      });

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mit GitHub anmelden'));
      await tester.pump(); // Start loading
      await tester.pump(); // Finish future

      verify(
        () => mockAuth.loginWithProvider(
          provider: OAuthProvider.github,
          scopes: ['user:email'],
        ),
      ).called(1);

      // Should verify navigation
      // Note: In a real app, Navigator.pushReplacementNamed replaces the route.
      // We can verify the new page is shown.
      expect(find.text('Shell Page'), findsOneWidget);
    });

    testWidgets('calls loginWithProvider (Google) and navigates on success', (
      tester,
    ) async {
      when(
        () => mockAuth.loginWithProvider(
          provider: any(named: 'provider'),
          scopes: any(named: 'scopes'),
        ),
      ).thenAnswer((_) async {
        when(() => mockAuth.status).thenReturn(AuthStatus.authenticated);
      });

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mit Google anmelden'));
      await tester.pump();
      await tester.pump();

      verify(
        () => mockAuth.loginWithProvider(
          provider: OAuthProvider.google,
          scopes: ['email', 'profile'],
        ),
      ).called(1);

      expect(find.text('Shell Page'), findsOneWidget);
    });

    testWidgets('shows error message on login failure', (tester) async {
      when(
        () => mockAuth.loginWithProvider(
          provider: any(named: 'provider'),
          scopes: any(named: 'scopes'),
        ),
      ).thenThrow(Exception('Network Error'));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mit GitHub anmelden'));
      await tester.pump(); // Start loading
      await tester.pump(); // Finish future/error

      expect(find.text('Login (GitHub) fehlgeschlagen'), findsOneWidget);

      // Should NOT navigate
      expect(find.text('Shell Page'), findsNothing);
    });
  });
}
