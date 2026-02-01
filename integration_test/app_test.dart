import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ai_handwriting_app/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note_page.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';

class MockConnectivityPlatform extends ConnectivityPlatform {
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.none]);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.none];
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  ConnectivityPlatform.instance = MockConnectivityPlatform();

  group('End-to-End Flow', () {
    testWidgets('Notiz erstellen und Editor öffnen', (tester) async {
      // Setup Mock for FlutterSecureStorage to avoid Libsecret errors on Linux
      const MethodChannel channel = MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      );
      final Map<String, String> storageMap = {};

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            final args = methodCall.arguments as Map?;
            final key = args?['key'] as String?;
            final value = args?['value'] as String?;

            switch (methodCall.method) {
              case 'read':
                return storageMap[key];
              case 'write':
                if (key != null && value != null) storageMap[key] = value;
                return null;
              case 'delete':
                if (key != null) storageMap.remove(key);
                return null;
              case 'deleteAll':
                storageMap.clear();
                return null;
              case 'containsKey':
                return storageMap.containsKey(key);
              default:
                return null;
            }
          });

      // Mock SharedPreferences, um das Onboarding zu überspringen
      SharedPreferences.setMockInitialValues({
        'inkpadu_cached_user_id': 'test-user-id',
        'inkpadu_cached_email': 'test@example.com',
        'inkpadu_has_logged_in': true,
      });

      // App starten
      await app.main();
      await tester.pumpAndSettle();

      // 1. Sicherstellen, dass wir auf der Home-Seite sind
      // Wir suchen spezifisch nach dem AppBar-Titel, um Mehrdeutigkeiten zu vermeiden
      expect(find.widgetWithText(AppBar, t.notes.title), findsOneWidget);

      // 2. "Neue Notiz" Button klicken
      final newNoteBtn = find.text(t.notes.newNote);
      expect(newNoteBtn, findsOneWidget);
      await tester.tap(newNoteBtn);
      await tester.pumpAndSettle();

      // 3. "Leere Notiz" im Bottom Sheet wählen
      final emptyNoteOption = find.text(t.notes.emptyNote);
      expect(emptyNoteOption, findsOneWidget);
      await tester.tap(emptyNoteOption);
      await tester.pumpAndSettle();

      // 4. Metadaten Dialog: Auf "Weiter" klicken
      // Wir suchen spezifisch nach dem TextButton, der "Weiter" enthält
      final nextBtn = find.widgetWithText(TextButton, t.common.next);
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // 5. Verifizieren, dass wir im Editor (DrawingNotePage) sind
      expect(find.byType(DrawingNotePage), findsOneWidget);

      // Optional: Zurück zur Home-Seite navigieren
      final backBtn = find.byIcon(Icons.arrow_back);
      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn);
        await tester.pumpAndSettle();
        expect(find.text(t.notes.title), findsOneWidget);
      }
    });
  });
}
