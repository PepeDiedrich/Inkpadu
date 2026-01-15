import 'package:ai_handwriting_app/features/editor/presentation/editor_page.dart';
import 'package:ai_handwriting_app/features/notes/domain/note.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EditorPage zeigt die initialen Inhalte an', (
    WidgetTester tester,
  ) async {
    final note = Note(
      id: 'note-1',
      title: 'Projektplan',
      content: 'Aufgabe 1\nAufgabe 2',
      updatedAt: DateTime(2024),
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: EditorPage(initialNote: note)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notiz bearbeiten'), findsOneWidget);
    expect(find.text('Projektplan'), findsOneWidget);
    expect(find.textContaining('Aufgabe 1'), findsOneWidget);
    expect(find.text('Speichern'), findsOneWidget);
  });
}
