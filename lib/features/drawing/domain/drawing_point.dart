import 'package:flutter/material.dart';

/// Repräsentiert einen einzelnen Punkt in einem gezeichneten Strich.
class DrawingPoint {
  /// Erstellt einen neuen Zeichenpunkt.
  DrawingPoint({required this.position, this.pressure = 0.5});

  /// Die 2D-Position des Punktes auf der Zeichenfläche.
  final Offset position;

  /// Die Druckstärke des Stiftes bei diesem Punkt (typischerweise zwischen 0.0 und 1.0).
  final double pressure;

  /// Wandelt das Objekt in eine JSON-Map um.
  Map<String, dynamic> toJson() => {
    'x': position.dx,
    'y': position.dy,
    'p': pressure,
  };

  /// Erstellt ein [DrawingPoint]-Objekt aus einer JSON-Map.
  factory DrawingPoint.fromJson(Map<String, dynamic> json) {
    final double x = (json['x'] as num?)?.toDouble() ?? 0.0;
    final double y = (json['y'] as num?)?.toDouble() ?? 0.0;
    final double rawPressure = (json['p'] as num?)?.toDouble() ?? 0.5;
    final double clampedPressure = rawPressure.clamp(0.0, 1.0).toDouble();

    return DrawingPoint(
      position: Offset(x, y),
      pressure: clampedPressure,
    );
  }
}
