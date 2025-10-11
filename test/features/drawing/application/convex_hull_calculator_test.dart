import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Stroke _strokeWithPoints(List<Offset> points, {double width = 4}) => Stroke(
    points: points
      .map((offset) => DrawingPoint(position: offset, pressure: 1))
      .toList(growable: false),
    baseWidth: width,
  );

List<Offset> _circlePoints({
  Offset center = Offset.zero,
  double radius = 30,
  int segments = 40,
}) {
  final List<Offset> points = <Offset>[];
  for (var i = 0; i <= segments; i++) {
    final double angle = (i / segments) * 2 * math.pi;
    final double dx = center.dx + radius * math.cos(angle);
    final double dy = center.dy + radius * math.sin(angle);
    points.add(Offset(dx, dy));
  }
  return points;
}

Rect _boundingBox(List<Offset> polygon) {
  var minX = double.infinity;
  var maxX = -double.infinity;
  var minY = double.infinity;
  var maxY = -double.infinity;
  for (final Offset point in polygon) {
    if (point.dx < minX) minX = point.dx;
    if (point.dx > maxX) maxX = point.dx;
    if (point.dy < minY) minY = point.dy;
    if (point.dy > maxY) maxY = point.dy;
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

Rect _unionBox(Iterable<List<Offset>> polygons) {
  Rect? box;
  for (final polygon in polygons) {
    final Rect current = _boundingBox(polygon);
    box = box == null ? current : box.expandToInclude(current);
  }
  return box ?? Rect.zero;
}

void main() {
  group('ConvexHullCalculator.contoursForStrokes', () {
    test('returns tight contour for rectangle stroke', () {
      final stroke = _strokeWithPoints(const [
        Offset(0, 0),
        Offset(0, 40),
        Offset(40, 40),
        Offset(40, 0),
        Offset(0, 0),
      ], width: 6);

      final contours = ConvexHullCalculator.contoursForStrokes([stroke]);

      expect(contours, isNotEmpty);
      final Rect box = _unionBox(contours);
      expect(box.left, lessThan(0));
      expect(box.top, lessThan(0));
      expect(box.right, greaterThan(40));
      expect(box.bottom, greaterThan(40));
    });

    test('produces combined contour for overlapping strokes', () {
      final strokes = [
        _strokeWithPoints(const [
          Offset(0, 0),
          Offset(0, 30),
          Offset(30, 30),
          Offset(30, 0),
          Offset(0, 0),
        ], width: 5),
        _strokeWithPoints(const [
          Offset(20, -10),
          Offset(20, 20),
          Offset(50, 20),
          Offset(50, -10),
          Offset(20, -10),
        ], width: 5),
      ];

      final contours = ConvexHullCalculator.contoursForStrokes(strokes);

      expect(contours, isNotEmpty);
      final Rect box = _unionBox(contours);
      expect(box.left, lessThan(0));
      expect(box.right, greaterThan(50));
    });

    test('captures very thin strokes', () {
      final stroke = _strokeWithPoints(const [
        Offset(10, 10),
        Offset(10, 70),
      ], width: 1.2);

      final contours = ConvexHullCalculator.contoursForStrokes([stroke]);

      expect(contours, isNotEmpty);
      final Rect box = _unionBox(contours);
      expect(box.top, lessThanOrEqualTo(10));
      expect(box.bottom, greaterThan(65));
      expect(box.width, greaterThan(3));
    });

    test('fills the interior of circular strokes', () {
      final stroke = _strokeWithPoints(
        _circlePoints(segments: 48),
        width: 5,
      );

      final contours = ConvexHullCalculator.contoursForStrokes([stroke]);

      expect(contours.length, 1);
      final Rect box = _unionBox(contours);
      expect(box.left, lessThan(-28));
      expect(box.right, greaterThan(28));
      expect(box.top, lessThan(-28));
      expect(box.bottom, greaterThan(28));
    });

    test('connects strokes that are close to each other', () {
      final strokes = [
        _strokeWithPoints(const [
          Offset(0, 0),
          Offset(0, 30),
          Offset(20, 30),
          Offset(20, 0),
          Offset(0, 0),
        ]),
        _strokeWithPoints(const [
          Offset(28, 2),
          Offset(28, 28),
          Offset(45, 28),
          Offset(45, 2),
          Offset(28, 2),
        ]),
      ];

      final contours = ConvexHullCalculator.contoursForStrokes(strokes);

      expect(contours, isNotEmpty);
      final Rect box = _unionBox(contours);
      expect(box.left, lessThan(0));
      expect(box.right, greaterThan(45));
      expect(box.width, lessThan(80));
    });

    test('returns empty list when no strokes present', () {
      expect(ConvexHullCalculator.contoursForStrokes(const []), isEmpty);
    });
  });
}
