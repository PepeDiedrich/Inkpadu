import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';

/// Repräsentiert eine einzelne Notizenseite, die eine Sammlung von Strichen enthält.
class NotePage {
  /// Erstellt eine neue Notizenseite.
  NotePage({required this.strokes});

  /// Die Liste aller Striche auf dieser Seite.
  final List<Stroke> strokes;

  /// Erstellt eine Kopie der Seite mit optional geänderten Werten.
  NotePage copyWith({
    List<Stroke>? strokes,
  }) =>
      NotePage(
        strokes: strokes ?? this.strokes,
      );

  /// Wandelt das Objekt in eine JSON-Map um.
  Map<String, dynamic> toJson() => {
        'strokes': strokes.map((s) => s.toJson()).toList(),
  };

  /// Erstellt ein [NotePage]-Objekt aus einer JSON-Map.
  factory NotePage.fromJson(Map<String, dynamic> json) {
    final Object? rawStrokes = json['strokes'];
    final List<Stroke> decodedStrokes = rawStrokes is List
        ? rawStrokes
            .whereType<Map<String, dynamic>>()
            .map(Stroke.fromJson)
            .toList(growable: false)
        : const <Stroke>[];

    return NotePage(
      strokes: decodedStrokes,
    );
  }
}
