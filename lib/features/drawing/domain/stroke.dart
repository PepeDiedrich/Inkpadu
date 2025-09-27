import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Stroke {
  // Einzigartige ID, um den Strich zweifelsfrei zu identifizieren
  final String id;

  // Die Liste der Punkte, aus denen der Strich besteht
  final List<DrawingPoint> points;

  // Eigenschaften des Strichs
  final Color color;
  final double baseWidth;
  final bool isHighlighter; // Beispiel für ein weiteres Attribut

  Stroke({
    required this.points,
    this.color = Colors.black,
    this.baseWidth = 4.0,
    this.isHighlighter = false,
    String? id,
  }) : id = id ?? Uuid().v4(); // Generiert eine zufällige, einzigartige ID

  // Auch hier Methoden für die JSON-Serialisierung
  Map<String, dynamic> toJson() => {
    'id': id,
    'points': points.map((p) => p.toJson()).toList(),
    'color': color.toARGB32(),
    'width': baseWidth,
    'isHighlighter': isHighlighter,
  };

  factory Stroke.fromJson(Map<String, dynamic> json) => Stroke(
    id: json['id'] as String,
    points: (json['points'] as List)
        .map((p) => DrawingPoint.fromJson(p as Map<String, dynamic>))
        .toList(),
    color: Color(json['color'] as int),
    baseWidth: json['width'] as double,
    isHighlighter: json['isHighlighter'] as bool,
  );
}
