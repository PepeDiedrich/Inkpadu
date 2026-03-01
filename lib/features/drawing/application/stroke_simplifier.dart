import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Wendet den Ramer-Douglas-Peucker-Algorithmus mit maximaler algorithmischer
/// Eleganz und Speichereffizienz auf die übergebenen [points] an.
List<DrawingPoint> simplifyStrokePoints(
  List<DrawingPoint> points, {
  double tolerance = 1.0,
}) {
  final length = points.length;
  if (length < 3) return List<DrawingPoint>.of(points);

  final sqTolerance = tolerance.isNaN || tolerance <= 0.0
      ? 0.0
      : tolerance * tolerance;

  // Ein boolesches Array dient als hochperformante Maske für zu erhaltende Punkte.
  final keepPoint = List<bool>.filled(length, false);
  keepPoint[0] = true;
  keepPoint[length - 1] = true;

  _rdpOptimize(points, 0, length - 1, sqTolerance, keepPoint);

  // Kompakte und elegante Extraktion der maskierten Punkte.
  return [
    for (var i = 0; i < length; i++)
      if (keepPoint[i]) points[i],
  ];
}

/// Vereinfacht einen [Stroke] durch Reduktion des Punkt-Sets.
Stroke simplifyStroke(Stroke stroke, {double tolerance = 1.0}) =>
    stroke.copyWith(
      points: simplifyStrokePoints(stroke.points, tolerance: tolerance),
    );

/// Rekursive, indexbasierte In-Place-Evaluation ohne Listen-Allokationen.
void _rdpOptimize(
  List<DrawingPoint> points,
  int startIndex,
  int endIndex,
  double sqTolerance,
  List<bool> keepPoint,
) {
  var maxSqDistance = 0.0;
  var splitIndex = 0;

  final start = points[startIndex].position;
  final end = points[endIndex].position;

  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;
  final lineSqLength = dx * dx + dy * dy;

  // For nearly closed loops, the distance calculation to the "line" (which is practically a point)
  // should use the distance to that point.
  final isClosedLoop = lineSqLength < sqTolerance * 0.1;

  for (var i = startIndex + 1; i < endIndex; i++) {
    final point = points[i].position;
    final double sqDistance;
    if (isClosedLoop) {
      final pdx = point.dx - start.dx;
      final pdy = point.dy - start.dy;
      sqDistance = pdx * pdx + pdy * pdy;
    } else {
      sqDistance = _sqPerpendicularDistance(point, start, dx, dy, lineSqLength);
    }

    if (sqDistance > maxSqDistance) {
      maxSqDistance = sqDistance;
      splitIndex = i;
    }
  }

  if (maxSqDistance > sqTolerance) {
    keepPoint[splitIndex] = true;
    _rdpOptimize(points, startIndex, splitIndex, sqTolerance, keepPoint);
    _rdpOptimize(points, splitIndex, endIndex, sqTolerance, keepPoint);
  }
}

/// Berechnet das Quadrat der lotrechten Distanz effizient ohne teure Wurzelziehen-Operationen.
double _sqPerpendicularDistance(
  Offset point,
  Offset start,
  double dx,
  double dy,
  double lineSqLength,
) {
  if (lineSqLength == 0.0) {
    final px = point.dx - start.dx;
    final py = point.dy - start.dy;
    return px * px + py * py;
  }

  // 2D-Kreuzprodukt zur Bestimmung der Fläche des Parallelogramms
  final crossProduct = dx * (point.dy - start.dy) - dy * (point.dx - start.dx);
  return (crossProduct * crossProduct) / lineSqLength;
}
