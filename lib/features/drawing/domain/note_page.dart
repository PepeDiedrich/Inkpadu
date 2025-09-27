import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';

/// Repräsentiert eine einzelne Notizenseite, die eine Sammlung von Strichen enthält.
class NotePage {
  /// Erstellt eine neue Notizenseite.
  NotePage({required this.strokes});

  /// Die Liste aller Striche auf dieser Seite.
  final List<Stroke> strokes;

  /// Wandelt das Objekt in eine JSON-Map um.
  Map<String, dynamic> toJson() => {
    'strokes': strokes.map((s) => s.toJson()).toList(),
  };

  /// Erstellt ein [NotePage]-Objekt aus einer JSON-Map.
  factory NotePage.fromJson(Map<String, dynamic> json) => NotePage(
    strokes: (json['strokes'] as List)
        .map((s) => Stroke.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}
