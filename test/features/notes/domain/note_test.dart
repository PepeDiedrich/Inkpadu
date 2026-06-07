import 'package:flutter_test/flutter_test.dart';

import 'package:inkpadu/features/notes/domain/note.dart';

void main() {
  test('displayTitle liefert einen Fallback für leere Titel', () {
    final note = Note(
      id: 'test',
      title: '',
      content: 'Inhalt',
      updatedAt: DateTime(2024),
    );

    expect(note.displayTitle, 'Unbenannte Notiz');
  });

  test('preview gibt die erste Textzeile zurück', () {
    final note = Note(
      id: 'test',
      title: 'Titel',
      content: 'Erste Zeile\nZweite Zeile',
      updatedAt: DateTime(2024),
    );

    expect(note.preview, 'Erste Zeile');
  });

  test('copyWith aktualisiert Inhalte und Zeitstempel', () {
    final original = Note(
      id: 'test',
      title: 'Alt',
      content: 'Alt',
      updatedAt: DateTime(2024),
    );

    final updated = original.copyWith(
      title: 'Neu',
      content: 'Neu',
      updatedAt: DateTime(2024, 2, 2),
    );

    expect(updated.id, original.id);
    expect(updated.title, 'Neu');
    expect(updated.content, 'Neu');
    expect(updated.updatedAt, DateTime(2024, 2, 2));
  });
}
