import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Gemeinsame Low-Level Routine zum Zeichnen eines einzelnen [Stroke].
void _paintStroke(Canvas canvas, Stroke stroke) {
  final paint = Paint()
    ..color = stroke.isHighlighter
        ? stroke.color.withValues(alpha: stroke.color.a * 0.5)
        : stroke.color
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  if (stroke.points.isEmpty) return;

  for (var i = 0; i < stroke.points.length - 1; i++) {
    final p1 = stroke.points[i];
    final p2 = stroke.points[i + 1];
    final width = stroke.baseWidth * (p1.pressure + p2.pressure) / 2;
    paint.strokeWidth = width;
    canvas.drawLine(p1.position, p2.position, paint);
  }
}

/// Malt alle abgeschlossenen Striche. Repaint nur wenn sich die Version ändert.
class FinishedStrokesPainter extends CustomPainter {
  FinishedStrokesPainter({required List<Stroke> strokes, required this.version})
    : strokes = List<Stroke>.unmodifiable(strokes);

  final List<Stroke> strokes;
  final int version; // Inkrementiert bei Änderungen an der Strichliste.

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
  CurrentStrokePainter({required this.currentStroke, required this.pointCount});

  final Stroke? currentStroke;
  final int pointCount;

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
