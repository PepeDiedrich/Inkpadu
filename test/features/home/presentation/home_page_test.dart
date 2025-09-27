import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_handwriting_app/features/home/presentation/home_page.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';

void main() {
  Widget wrapWithScopes(Widget child, {InkNotesController? controller}) {
    final notes = controller ?? InkNotesController();
    final pointer = PointerSettings();
    return InkNotesScope(
      controller: notes,
      child: PointerSettingsScope(
        settings: pointer,
        child: MaterialApp(home: child),
      ),
    );
  }

  testWidgets('Liste zeigt neu erstellte Notiz per FAB', (tester) async {
    await tester.pumpWidget(wrapWithScopes(const HomePage()));

    // Leerer Zustand Text prüfen
    expect(find.text('Noch keine handschriftlichen Notizen'), findsOneWidget);

    // Neue Notiz via FAB
    await tester.tap(find.byIcon(Icons.add));
    // Begrenztes Warten statt unendlichem pumpAndSettle (Navigation animiert)
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.textContaining('Notiz ').evaluate().isNotEmpty) break;
    }

    // Wir sind jetzt auf der Zeichen-Seite, Titel der Auto-Notiz sollte oben stehen
    expect(find.textContaining('Notiz '), findsOneWidget);

    // Zurück zur Liste
    // Zurück zur Liste über Navigator.pop (stabiler in Tests als pageBack bei MaterialApp ohne NavigatorBar)
    Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 30));
      if (find.byType(ListTile).evaluate().isNotEmpty) break;
    }

    // Die eben angelegte Notiz erscheint nun in der Übersicht
    expect(find.textContaining('Notiz '), findsOneWidget);
  });

  testWidgets('Mehrere Notizen erscheinen (>=2) in Übersicht', (tester) async {
    final controller = InkNotesController();
    // Zwei vorhandene Notizen anlegen (verschiedene IDs & Timestamps)
    // Erzeuge zwei Notizen ohne künstliche Delays (IDs durch Microseconds bereits unterschiedlich)
    controller.upsert(InkNote.empty());
    controller.upsert(InkNote.empty());

    await tester.pumpWidget(
      wrapWithScopes(const HomePage(), controller: controller),
    );

    // Kurzes Pump für Rebuild
    await tester.pump();
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
