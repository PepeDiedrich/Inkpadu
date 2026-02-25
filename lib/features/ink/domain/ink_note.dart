import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
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
    required this.pages,
    required this.paperStyle,
    this.lastOpenedPageIndex = 0,
  });

  /// Eindeutige ID.
  final String id;

  /// Titel (automatisch generiert, kann später geändert werden).
  final String title;

  /// Zeitpunkt der letzten Änderung.
  final DateTime updatedAt;

  /// Alle Seiten der Notiz in Reihenfolge.
  final List<NotePage> pages;

  /// Index der Seite, die zuletzt geöffnet bzw. verlassen wurde.
  final int lastOpenedPageIndex;

  /// Liefert die aktuell aktive Seite basierend auf [lastOpenedPageIndex].
  NotePage get currentPage {
    if (pages.isEmpty) {
      return NotePage(strokes: const <Stroke>[]);
    }
    final idx = lastOpenedPageIndex.clamp(0, pages.length - 1);
    return pages[idx];
  }

  /// Der gewählte Papier- bzw. Hintergrundstil.
  final NotePaperStyle paperStyle;

  /// Kopie mit geänderten Feldern.
  InkNote copyWith({
    String? title,
    DateTime? updatedAt,
    List<NotePage>? pages,
    NotePaperStyle? paperStyle,
    int? lastOpenedPageIndex,
  }) => InkNote(
    id: id,
    title: title ?? this.title,
    updatedAt: updatedAt ?? this.updatedAt,
    pages: pages ?? this.pages,
    paperStyle: paperStyle ?? this.paperStyle,
    lastOpenedPageIndex: lastOpenedPageIndex ?? this.lastOpenedPageIndex,
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
      pages: List<NotePage>.unmodifiable(<NotePage>[
        NotePage(strokes: const <Stroke>[]),
      ]),
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
