import 'package:flutter/material.dart';

/// CustomPainter der einfache handschriftliche Linien rendert.
class DrawingPainter extends CustomPainter {
  /// Erstellt einen DrawingPainter.
  ///
  /// [paths] enthält abgeschlossene Linien, [currentPath] die aktuell entstehende Linie.
  DrawingPainter({
    required this.paths,
    required this.currentPath,
    this.strokeColor = Colors.black,
    this.strokeWidth = 4.0,
  });

  /// Abgeschlossene Pfade (jede Liste ist eine Linie aus Offsets).
  /// Abgeschlossene Linien.
  final List<List<Offset>> paths;

  /// Aktueller, noch nicht abgeschlossener Pfad.
  /// Aktuelle, noch nicht abgeschlossene Linie.
  final List<Offset> currentPath;

  /// Linienfarbe.
  /// Farbe der Linien.
  final Color strokeColor;

  /// Linienbreite.
  /// Strichstärke der Linien.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    void drawSegments(List<Offset> pts) {
      for (var i = 0; i < pts.length - 1; i++) {
        canvas.drawLine(pts[i], pts[i + 1], paint);
      }
    }

    for (final path in paths) {
      if (path.length > 1) drawSegments(path);
    }
    if (currentPath.length > 1) drawSegments(currentPath);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) =>
      oldDelegate.paths != paths ||
      oldDelegate.currentPath != currentPath ||
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
