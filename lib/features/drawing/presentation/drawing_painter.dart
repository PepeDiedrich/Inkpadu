import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Gemeinsame Low-Level Routine zum Zeichnen eines einzelnen [Stroke].
void _paintStroke(Canvas canvas, Stroke stroke) {
  if (stroke.points.isEmpty) return;

  final paint = Paint()
    ..color = stroke.isHighlighter
        ? stroke.color.withValues(alpha: stroke.color.a * 0.5)
        : stroke.color
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  // Optimization: If the stroke has constant pressure (common for mouse or
  // non-pressure-sensitive styluses), we can draw the entire path at once
  // using canvas.drawPath. This is significantly faster than drawing
  // hundreds of individual line segments.
  if (stroke.isConstantPressure) {
    if (stroke.cachedPath == null) {
      final path = Path();
      path.moveTo(stroke.points.first.position.dx, stroke.points.first.position.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].position.dx, stroke.points[i].position.dy);
      }
      stroke.cachedPath = path;
    }

    // Since pressure is constant, we can use the pressure of the first point
    // to calculate the uniform width.
    paint.strokeWidth = stroke.baseWidth * stroke.points.first.pressure;
    // Set strokeJoin to round to match the visual style of round-capped segments.
    paint.strokeJoin = StrokeJoin.round;

    canvas.drawPath(stroke.cachedPath!, paint);
  } else {
    // Fallback: For variable pressure strokes, we must draw individual segments
    // to modulate the width at each step.
    for (var i = 0; i < stroke.points.length - 1; i++) {
      final p1 = stroke.points[i];
      final p2 = stroke.points[i + 1];
      final width = stroke.baseWidth * (p1.pressure + p2.pressure) / 2;
      paint.strokeWidth = width;
      canvas.drawLine(p1.position, p2.position, paint);
    }
  }
}

/// Malt alle abgeschlossenen Striche. Repaint nur wenn sich die Version ändert.
class FinishedStrokesPainter extends CustomPainter {
  /// Erstellt einen Painter für bereits abgeschlossene Striche.
  FinishedStrokesPainter({required List<Stroke> strokes, required this.version})
    : strokes = List<Stroke>.unmodifiable(strokes);

  /// Alle abgeschlossenen Striche auf der Seite.
  final List<Stroke> strokes;

  /// Version der Strichliste. Erhöht sich bei jeder strukturellen Änderung
  /// (Undo, Redo, Clear, Abschluss eines Strichs). Dient für shouldRepaint.
  final int version;

  /// Zeichnet alle abgeschlossenen Striche auf die Leinwand.
  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant FinishedStrokesPainter oldDelegate) =>
      oldDelegate.version != version;
}

/// Malt den aktuell entstehenden Strich. Repaint nur bei neuem Objekt oder
/// veränderter Punktzahl (wächst während des Zeichnens).
class CurrentStrokePainter extends CustomPainter {
  /// Erstellt einen Painter für den aktuell entstehenden Strich.
  CurrentStrokePainter({required this.currentStroke, required this.pointCount});

  /// Der aktuell gezeichnete, noch nicht abgeschlossene Strich.
  final Stroke? currentStroke;

  /// Aktuelle Anzahl der Punkte im Strich. Wächst während des Zeichnens.
  final int pointCount;

  /// Zeichnet den aktuell entstehenden Strich auf die Leinwand.
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = currentStroke;
    if (stroke == null) return;
    _paintStroke(canvas, stroke);
  }

  @override
  bool shouldRepaint(covariant CurrentStrokePainter oldDelegate) =>
      oldDelegate.currentStroke != currentStroke ||
      oldDelegate.pointCount != pointCount;
}
