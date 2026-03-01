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
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke
    ..strokeWidth = stroke.baseWidth;

  if (stroke.points.length == 1) {
    canvas.drawCircle(
      stroke.points.first.position,
      stroke.baseWidth / 2,
      paint..style = PaintingStyle.fill,
    );
    return;
  }

  final path = Path();
  path.moveTo(stroke.points[0].position.dx, stroke.points[0].position.dy);

  for (var i = 0; i < stroke.points.length - 1; i++) {
    final p1 = stroke.points[i].position;
    final p2 = stroke.points[i + 1].position;

    // We use quadratic Bézier curves for smoothing.
    // The control point is p1, and the end point is the midpoint between p1 and p2.
    final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    path.quadraticBezierTo(p1.dx, p1.dy, midPoint.dx, midPoint.dy);
  }

  // Connect to the last point
  path.lineTo(stroke.points.last.position.dx, stroke.points.last.position.dy);

  canvas.drawPath(path, paint);
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
