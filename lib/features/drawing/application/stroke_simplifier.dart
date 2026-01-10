import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Wendet den Ramer-Douglas-Peucker Algorithmus auf die übergebenen [points] an.
///
/// Der Algorithmus reduziert die Anzahl der Punkte, indem er diejenigen entfernt,
/// die auf einer nahezu geraden Linie zwischen zwei anderen Punkten liegen.
/// Die charakteristische Form des Strichs bleibt dabei erhalten.
List<DrawingPoint> simplifyStrokePoints(
  List<DrawingPoint> points, {
  double tolerance = 1.0,
}) {
  if (points.length < 3) {
    return List<DrawingPoint>.of(points);
  }

  final sanitizedTolerance = tolerance.isNaN
      ? 0.0
      : tolerance.clamp(0, double.infinity).toDouble();

  return _rdp(points, sanitizedTolerance);
}

/// Vereinfacht einen [Stroke] und gibt eine neue Instanz mit reduziertem Punkt-Set zurück.
Stroke simplifyStroke(Stroke stroke, {double tolerance = 1.0}) {
  final simplifiedPoints = simplifyStrokePoints(
    stroke.points,
    tolerance: tolerance,
  );
  return stroke.copyWith(points: simplifiedPoints);
}

List<DrawingPoint> _rdp(List<DrawingPoint> points, double tolerance) {
  if (points.length < 3) {
    return List<DrawingPoint>.of(points);
  }

  final first = points.first;
  final last = points.last;

  var index = 0;
  var maxDistance = 0.0;

  for (var i = 1; i < points.length - 1; i++) {
    final distance = _perpendicularDistance(
      points[i].position,
      first.position,
      last.position,
    );
    if (distance > maxDistance) {
      maxDistance = distance;
      index = i;
    }
  }

  if (maxDistance <= tolerance) {
    return <DrawingPoint>[first, if (!_samePoint(first, last)) last];
  }

  final left = _rdp(points.sublist(0, index + 1), tolerance);
  final right = _rdp(points.sublist(index, points.length), tolerance);

  return <DrawingPoint>[...left.take(left.length - 1), ...right];
}

bool _samePoint(DrawingPoint a, DrawingPoint b) =>
    a.position == b.position && a.pressure == b.pressure;

double _perpendicularDistance(Offset point, Offset lineStart, Offset lineEnd) {
  final line = lineEnd - lineStart;
  if (line.distanceSquared == 0) {
    return (point - lineStart).distance;
  }

  final ap = point - lineStart;
  final cross = (line.dx * ap.dy) - (line.dy * ap.dx);
  return cross.abs() / line.distance;
}
