import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Beschreibt einen einzelnen Strich innerhalb einer handschriftlichen Notiz.
class Stroke {
  /// Einzigartige ID, um den Strich zweifelsfrei zu identifizieren.
  final String id;

  /// Die Liste der Punkte, aus denen der Strich besteht.
  final List<DrawingPoint> points;

  /// Farbe des Strichs.
  final Color color;

  /// Basis-Linienbreite, die zusammen mit dem Druck einen finalen Wert ergibt.
  final double baseWidth;

  /// Kennzeichnet, ob es sich um einen Textmarker-Strich handelt.
  final bool isHighlighter;

  /// Erstellt eine neue Instanz eines Strichs.
  Stroke({
    required this.points,
    this.color = Colors.black,
    this.baseWidth = 4.0,
    this.isHighlighter = false,
    String? id,
  }) : id = id ?? const Uuid().v4();

  /// Gibt eine Kopie des Strichs mit optional geänderten Werten zurück.
  Stroke copyWith({
    List<DrawingPoint>? points,
    Color? color,
    double? baseWidth,
    bool? isHighlighter,
    String? id,
  }) => Stroke(
    id: id ?? this.id,
    points: points ?? this.points,
    color: color ?? this.color,
    baseWidth: baseWidth ?? this.baseWidth,
    isHighlighter: isHighlighter ?? this.isHighlighter,
  );

  /// Wandelt den Strich in eine JSON-Map um.
  Map<String, dynamic> toJson() => {
    'id': id,
    'points': points.map((p) => p.toJson()).toList(),
    'color': color.toARGB32(),
    'width': baseWidth,
    'isHighlighter': isHighlighter,
  };

  /// Erstellt einen Strich aus einer JSON-Map.
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
