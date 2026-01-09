import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart'
    show RotatedBoundingBox;
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Shared Paint object to avoid allocation in the loop.
final Paint _sharedPaint = Paint()
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke;

/// Gemeinsame Low-Level Routine zum Zeichnen eines einzelnen [Stroke].
void _paintStroke(Canvas canvas, Stroke stroke) {
  _sharedPaint.color = stroke.isHighlighter
      ? stroke.color.withValues(alpha: stroke.color.a * 0.5)
      : stroke.color;

  if (stroke.points.isEmpty) return;

  // Optimization: If pressure is constant or it's a highlighter, use drawPath.
  // This reduces JNI calls and fixes highlighter overlap artifacts.
  final canUseFastPath = stroke.points.length >= 2 &&
      (stroke.isHighlighter || stroke.isConstantPressure);

  if (canUseFastPath) {
    Path? path = stroke.cachedPath;
    if (path == null) {
      path = Path();
      path.moveTo(stroke.points[0].position.dx, stroke.points[0].position.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].position.dx, stroke.points[i].position.dy);
      }
      stroke.cachedPath = path;
    }

    // Use average pressure for width (they are constant anyway)
    final double avgPressure = stroke.points.isNotEmpty
        ? stroke.points[0].pressure
        : 1.0;

    _sharedPaint.strokeWidth = stroke.baseWidth * avgPressure;
    _sharedPaint.strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, _sharedPaint);
    return;
  }

  for (var i = 0; i < stroke.points.length - 1; i++) {
    final p1 = stroke.points[i];
    final p2 = stroke.points[i + 1];
    final width = stroke.baseWidth * (p1.pressure + p2.pressure) / 2;
    _sharedPaint.strokeWidth = width;
    canvas.drawLine(p1.position, p2.position, _sharedPaint);
  }
}

/// Malt alle abgeschlossenen Striche. Repaint nur wenn sich die Version ändert.
class FinishedStrokesPainter extends CustomPainter {
  /// Erstellt einen Painter für bereits abgeschlossene Striche.
  const FinishedStrokesPainter({required this.strokes, required this.version});

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

/// Zeichnet konvexe Hüllen als Debug-Overlay.
class ConvexHullsPainter extends CustomPainter {
  /// Erstellt einen Painter zur Visualisierung konvexer Hüllen.
  const ConvexHullsPainter({
    required this.hulls,
    required this.boundingBoxes,
  });

  /// Liste konvexer Hüllen (jede Hülle ist eine geschlossene Polygonkette).
  final List<List<Offset>> hulls;

  /// Minimale Bounding-Boxen zu den jeweiligen Hüllen.
  final List<RotatedBoundingBox> boundingBoxes;

  static const Color _strokeColor = Color(0xFFFFC107);
  static const Color _fillColor = Color(0x33FFC107);
  static const Color _boundingStrokeColor = Color(0xFF2962FF);
  static const Color _boundingFillColor = Color(0x1A2962FF);

  @override
  void paint(Canvas canvas, Size size) {
    if (hulls.isEmpty) {
      return;
    }

    final Paint fillPaint = Paint()
      ..color = _fillColor
      ..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..color = _strokeColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final Paint boundingFillPaint = Paint()
      ..color = _boundingFillColor
      ..style = PaintingStyle.fill;
    final Paint boundingStrokePaint = Paint()
      ..color = _boundingStrokeColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final hull in hulls) {
      if (hull.length < 2) {
        continue;
      }
      final path = Path()..addPolygon(hull, true);
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }

    for (final RotatedBoundingBox box in boundingBoxes) {
      if (box.corners.isEmpty) {
        continue;
      }
      final Path boxPath = Path()..addPolygon(box.corners, true);
      if (box.width > 0 && box.height > 0) {
        canvas.drawPath(boxPath, boundingFillPaint);
      }
      canvas.drawPath(boxPath, boundingStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConvexHullsPainter oldDelegate) =>
      oldDelegate.hulls != hulls ||
      oldDelegate.boundingBoxes != boundingBoxes;
}
