import 'package:flutter/material.dart';

/// Repräsentiert einen einzelnen Punkt in einem gezeichneten Strich.
class DrawingPoint {
  /// Erstellt einen neuen Zeichenpunkt.
  DrawingPoint({required this.position});

  /// Die 2D-Position des Punktes auf der Zeichenfläche.
  final Offset position;

  /// Wandelt das Objekt in eine JSON-Map um.
  Map<String, dynamic> toJson() => {'x': position.dx, 'y': position.dy};

  /// Erstellt ein [DrawingPoint]-Objekt aus einer JSON-Map.
  factory DrawingPoint.fromJson(Map<String, dynamic> json) {
    final double x = (json['x'] as num?)?.toDouble() ?? 0.0;
    final double y = (json['y'] as num?)?.toDouble() ?? 0.0;

    return DrawingPoint(position: Offset(x, y));
  }
}
