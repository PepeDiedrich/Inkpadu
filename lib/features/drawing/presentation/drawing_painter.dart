import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Ein [CustomPainter], der eine Liste von [Stroke]-Objekten auf eine Leinwand zeichnet.
class DrawingPainter extends CustomPainter {
  /// Erstellt einen neuen [DrawingPainter].
  DrawingPainter({List<Stroke>? strokes, this.currentStroke})
    : strokes = List<Stroke>.unmodifiable(strokes ?? const []);

  /// Alle abgeschlossenen Striche auf der Seite.
  final List<Stroke> strokes;

  /// Der aktuell gezeichnete, noch nicht abgeschlossene Strich.
  final Stroke? currentStroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
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

      // Dynamische Strichstärke basierend auf Druck
      final width = stroke.baseWidth * (p1.pressure + p2.pressure) / 2;
      paint.strokeWidth = width;

      canvas.drawLine(p1.position, p2.position, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) =>
      !listEquals(oldDelegate.strokes, strokes) ||
      oldDelegate.currentStroke != currentStroke;
}
