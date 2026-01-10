import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/app/auth/auth_scope.dart';
import 'package:ai_handwriting_app/features/settings/presentation/settings_page.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthController extends Mock implements AuthController {}

void main() {
  late MockAuthController mockAuthController;

  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.de);
  });

  setUp(() {
    mockAuthController = MockAuthController();
    when(() => mockAuthController.isLoggedIn).thenReturn(false);
    when(() => mockAuthController.status).thenReturn(AuthStatus.unauthenticated);
  });

  Widget createSubject() {
    return TranslationProvider(
      child: AuthScope(
        controller: mockAuthController,
        child: MaterialApp(
          locale: LocaleSettings.currentLocale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const SettingsPage(),
        ),
      ),
    );
  }

  group('SettingsPage', () {
    testWidgets('renders all settings sections', (tester) async {
      // Set a large height to ensure all items are rendered (avoiding lazy loading culling)
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Einstellungen'), findsOneWidget);
      expect(find.text('Allgemein'), findsOneWidget);
      expect(find.text('Eingabe'), findsOneWidget);
      expect(find.text('KI-Assistent'), findsOneWidget);
      expect(find.text('Cloud & Synchronisation'), findsOneWidget);
    });

    testWidgets('shows logout section only when logged in', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockAuthController.isLoggedIn).thenReturn(true);
      when(() => mockAuthController.status).thenReturn(AuthStatus.authenticated);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Konto'), findsOneWidget);
      expect(find.text('Abmelden'), findsOneWidget);
    });

    testWidgets('hides logout section when logged out', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockAuthController.isLoggedIn).thenReturn(false);
      when(() => mockAuthController.status).thenReturn(AuthStatus.unauthenticated);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Konto'), findsNothing);
      expect(find.text('Abmelden'), findsNothing);
    });

    testWidgets('triggers logout on tap', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockAuthController.isLoggedIn).thenReturn(true);
      when(() => mockAuthController.status).thenReturn(AuthStatus.authenticated);
      when(() => mockAuthController.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abmelden'));
      await tester.pump();

      verify(() => mockAuthController.logout()).called(1);
      expect(find.text('Abgemeldet'), findsOneWidget);
    });
  });
}
