import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:flutter/foundation.dart';

/// Repräsentiert eine handschriftliche Notiz bestehend aus mehreren Strichen.
@immutable
class InkNote {
  /// Erstellt eine neue handschriftliche Notiz.
  const InkNote({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.page,
  });

  /// Eindeutige ID.
  final String id;

  /// Titel (automatisch generiert, kann später geändert werden).
  final String title;

  /// Zeitpunkt der letzten Änderung.
  final DateTime updatedAt;

  /// Die Seite, die alle Zeichenelemente enthält.
  final NotePage page;

  /// Kopie mit geänderten Feldern.
  InkNote copyWith({String? title, DateTime? updatedAt, NotePage? page}) =>
      InkNote(
        id: id,
        title: title ?? this.title,
        updatedAt: updatedAt ?? this.updatedAt,
        page: page ?? this.page,
      );

  /// Erzeugt eine leere neue Notiz mit generiertem Titel.
  factory InkNote.empty() {
    final now = DateTime.now();
    return InkNote(
      id: now.microsecondsSinceEpoch.toString(),
      title: _autoTitle(now),
      updatedAt: now,
      page: NotePage(strokes: []),
    );
  }

  static String _autoTitle(DateTime dt) {
    final d = dt.toLocal();
    final date =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return 'Notiz $date $time';
  }
}
