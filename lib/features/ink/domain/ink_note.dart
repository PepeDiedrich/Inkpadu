import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
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
    required this.paperStyle,
  });

  /// Eindeutige ID.
  final String id;

  /// Titel (automatisch generiert, kann später geändert werden).
  final String title;

  /// Zeitpunkt der letzten Änderung.
  final DateTime updatedAt;

  /// Die Seite, die alle Zeichenelemente enthält.
  final NotePage page;

  /// Der gewählte Papier- bzw. Hintergrundstil.
  final NotePaperStyle paperStyle;

  /// Kopie mit geänderten Feldern.
  InkNote copyWith({
    String? title,
    DateTime? updatedAt,
    NotePage? page,
    NotePaperStyle? paperStyle,
  }) => InkNote(
    id: id,
    title: title ?? this.title,
    updatedAt: updatedAt ?? this.updatedAt,
    page: page ?? this.page,
    paperStyle: paperStyle ?? this.paperStyle,
  );

  /// Erzeugt eine leere neue Notiz mit generiertem Titel.
  factory InkNote.empty({
    String? id,
    String? title,
    DateTime? timestamp,
    NotePaperStyle paperStyle = NotePaperStyle.plain,
  }) {
    final now = (timestamp ?? DateTime.now()).toLocal();
    return InkNote(
      id: id ?? now.microsecondsSinceEpoch.toString(),
      title: title ?? generateTitle(now),
      updatedAt: now,
      page: NotePage(strokes: []),
      paperStyle: paperStyle,
    );
  }

  /// Generiert einen neuen Titel basierend auf Datum und Uhrzeit.
  static String generateTitle([DateTime? timestamp]) {
    final d = (timestamp ?? DateTime.now()).toLocal();
    final date =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return 'Notiz $date $time';
  }
}
