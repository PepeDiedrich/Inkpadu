import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Repräsentiert eine handschriftliche Notiz bestehend aus mehreren Strichen.
@immutable
class InkNote {
  const InkNote({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.strokes,
  });

  /// Eindeutige ID.
  final String id;

  /// Titel (automatisch generiert, kann später geändert werden).
  final String title;

  /// Zeitpunkt der letzten Änderung.
  final DateTime updatedAt;

  /// Liste der Striche; ein Strich = Liste von Offsets.
  /// Alle Striche dieser Notiz.
  final List<List<Offset>> strokes;

  /// Kopie mit geänderten Feldern.
  InkNote copyWith({
    String? title,
    DateTime? updatedAt,
    List<List<Offset>>? strokes,
  }) => InkNote(
    id: id,
    title: title ?? this.title,
    updatedAt: updatedAt ?? this.updatedAt,
    strokes: strokes ?? this.strokes,
  );

  /// Erzeugt eine leere neue Notiz mit generiertem Titel.
  factory InkNote.empty() {
    final now = DateTime.now();
    return InkNote(
      id: now.microsecondsSinceEpoch.toString(),
      title: _autoTitle(now),
      updatedAt: now,
      strokes: <List<Offset>>[],
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
