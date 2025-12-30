import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ai_handwriting_app/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Flow', () {
    testWidgets('Notiz erstellen und Editor öffnen', (tester) async {
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
