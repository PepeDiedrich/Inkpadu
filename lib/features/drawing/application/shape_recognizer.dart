import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:flutter/material.dart';

enum ShapeType {
  line,
  // potentially other shapes later: circle, rectangle, etc.
}

class ShapeMatch {
  final ShapeType type;
  final List<DrawingPoint> correctedPoints;

  ShapeMatch({required this.type, required this.correctedPoints});
}

class ShapeRecognizer {
  /// Versucht, aus den gegebenen Punkten eine geometrische Form zu erkennen.
  ///
  /// [tolerance] gibt den maximal erlaubten durchschnittlichen oder absoluten Abstand
  /// der Punkte zur idealen Form an.
  static ShapeMatch? recognizeShape(List<DrawingPoint> points, double tolerance) {
    if (points.length < 2) {
      return null;
    }

    // 1. Check for Line
    if (_isLine(points, tolerance)) {
      final start = points.first;
      final end = points.last;
      return ShapeMatch(
        type: ShapeType.line,
        correctedPoints: [start, end],
      );
    }

    return null;
  }

  static bool _isLine(List<DrawingPoint> points, double tolerance) {
    final start = points.first.position;
    final end = points.last.position;

    // Avoid division by zero if start == end
    if ((start - end).distanceSquared < 1.0) {
      // If all points are clustered at one spot, technically it's a "line" (point),
      // but practically we usually want a stroke. However, if user holds on a point...
      // Let's assume a line must have some length to be snapped?
      // User request: "straight line and pauses". Usually implies drawing a line.
      // If length is tiny, maybe we shouldn't snap.
      return false;
    }

    double maxDistance = 0.0;

    for (final point in points) {
      final double distance = _distanceToLineSegment(point.position, start, end);
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }

    return maxDistance <= tolerance;
  }

  /// Calculates perpendicular distance from point P to line segment AB.
  static double _distanceToLineSegment(Offset p, Offset a, Offset b) {
    final double l2 = (b - a).distanceSquared;
    if (l2 == 0) return (p - a).distance;

    // Consider the line extending the segment, parameterized as a + t (b - a).
    // We find projection of point p onto the line.
    // It falls where t = [(p-a) . (b-a)] / |b-a|^2
    final double t = ((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2;

    // We clamp t from [0,1] to handle points projected outside the segment
    // (though for shape recognition of a drawn stroke, points are usually "between" start and end index-wise,
    // but spatially they could loop back. Clamping is safer).
    final double tClamped = t.clamp(0.0, 1.0);

    final double projectionX = a.dx + tClamped * (b.dx - a.dx);
    final double projectionY = a.dy + tClamped * (b.dy - a.dy);

    final double dx = p.dx - projectionX;
    final double dy = p.dy - projectionY;

    return math.sqrt(dx * dx + dy * dy);
  }
}
