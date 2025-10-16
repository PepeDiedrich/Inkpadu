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

bool _anglesApproximatelyEquivalent(
  double a,
  double b, {
  double epsilon = 1e-6,
}) {
  double normalize(double angle) {
    final double twoPi = 2 * math.pi;
    double normalized = angle % twoPi;
    if (normalized > math.pi) {
      normalized -= twoPi;
    } else if (normalized < -math.pi) {
      normalized += twoPi;
    }
    return normalized;
  }

  for (final double offset in <double>[0, math.pi / 2, math.pi, 3 * math.pi / 2]) {
    if (normalize(a - (b + offset)).abs() <= epsilon) {
      return true;
    }
  }
  return false;
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
  expect(box.width, lessThanOrEqualTo(80));
    });

    test('returns empty list when no strokes present', () {
      expect(ConvexHullCalculator.contoursForStrokes(const []), isEmpty);
    });
  });

  group('ConvexHullCalculator.minimalBoundingBoxForPolygon', () {
    test('matches axis-aligned rectangle', () {
      const List<Offset> polygon = <Offset>[
        Offset(10, 20),
        Offset(60, 20),
        Offset(60, 50),
        Offset(10, 50),
      ];

      final RotatedBoundingBox? box =
          ConvexHullCalculator.minimalBoundingBoxForPolygon(polygon);

      expect(box, isNotNull);
      expect(box!.width, moreOrLessEquals(50, epsilon: 1e-3));
      expect(box.height, moreOrLessEquals(30, epsilon: 1e-3));
      expect(box.angle, moreOrLessEquals(0, epsilon: 1e-6));
      for (final Offset corner in polygon) {
        expect(
          box.corners.any((Offset candidate) =>
              (candidate - corner).distance <= 1e-3),
          isTrue,
        );
      }
    });

    test('recovers rotated rectangle', () {
      const double angle = math.pi / 7; // ca. 25.7°
      const double halfWidth = 40;
      const double halfHeight = 18;

      Offset rotatePoint(Offset point) {
        final double cosAngle = math.cos(angle);
        final double sinAngle = math.sin(angle);
        return Offset(
          point.dx * cosAngle - point.dy * sinAngle,
          point.dx * sinAngle + point.dy * cosAngle,
        );
      }

      final List<Offset> rectangle = <Offset>[
        const Offset(-halfWidth, -halfHeight),
        const Offset(halfWidth, -halfHeight),
        const Offset(halfWidth, halfHeight),
        const Offset(-halfWidth, halfHeight),
      ].map(rotatePoint).toList(growable: false);

      final RotatedBoundingBox? box =
          ConvexHullCalculator.minimalBoundingBoxForPolygon(rectangle);

      expect(box, isNotNull);
      final List<double> dimensions = <double>[box!.width, box.height]
        ..sort();
      final List<double> expectedDimensions = <double>[
        halfWidth * 2,
        halfHeight * 2,
      ]..sort();
      for (var i = 0; i < dimensions.length; i++) {
        expect(
          dimensions[i],
          moreOrLessEquals(expectedDimensions[i], epsilon: 1e-2),
        );
      }
      // Winkel kann um pi versetzt sein – vergleiche über Sinus/Cosinus.
      expect(
        _anglesApproximatelyEquivalent(box.angle, angle),
        isTrue,
      );
      for (final Offset vertex in rectangle) {
        expect(
          box.corners.any((Offset corner) =>
              (corner - vertex).distance <= 1e-2),
          isTrue,
        );
      }
    });

    test('handles single point polygon', () {
      const Offset point = Offset(5, -7);

      final RotatedBoundingBox? box =
          ConvexHullCalculator.minimalBoundingBoxForPolygon(const [point]);

      expect(box, isNotNull);
      expect(box!.width, 0);
      expect(box.height, 0);
      expect(box.center, point);
      for (final Offset corner in box.corners) {
        expect(corner, point);
      }
    });
  });

  group('ConvexHullCalculator.boundingBoxesForContours', () {
    test('uses stroke points within contour and adds radius margin', () {
      final Stroke stroke = _strokeWithPoints(const [
        Offset(0, 0),
        Offset(0, 10),
        Offset(10, 10),
        Offset(10, 0),
        Offset(0, 0),
      ], width: 6);
      final List<List<Offset>> contours = <List<Offset>>[
        const [
          Offset(-5, -5),
          Offset(15, -5),
          Offset(15, 15),
          Offset(-5, 15),
        ],
      ];

      final List<RotatedBoundingBox> boxes =
          ConvexHullCalculator.boundingBoxesForContours(contours, [stroke]);

      expect(boxes, hasLength(1));
      final Rect rect = _boundingBox(boxes.single.corners);
      expect(rect.left, moreOrLessEquals(-3, epsilon: 1e-6));
      expect(rect.top, moreOrLessEquals(-3, epsilon: 1e-6));
      expect(rect.right, moreOrLessEquals(13, epsilon: 1e-6));
      expect(rect.bottom, moreOrLessEquals(13, epsilon: 1e-6));
    });

    test('groups strokes per contour', () {
      final Stroke strokeA = _strokeWithPoints(const [
        Offset(0, 0),
        Offset(20, 0),
      ]);
      final Stroke strokeB = _strokeWithPoints(const [
        Offset(40, 40),
        Offset(60, 40),
      ]);

      final List<List<Offset>> contours = <List<Offset>>[
        const [Offset(-10, -10), Offset(30, -10), Offset(30, 20), Offset(-10, 20)],
        const [Offset(30, 30), Offset(70, 30), Offset(70, 60), Offset(30, 60)],
      ];

      final List<RotatedBoundingBox> boxes =
          ConvexHullCalculator.boundingBoxesForContours(
        contours,
        [strokeA, strokeB],
      );

      expect(boxes, hasLength(2));
      final Rect rectA = _boundingBox(boxes[0].corners);
      final Rect rectB = _boundingBox(boxes[1].corners);
      expect(rectA.left, lessThan(0));
      expect(rectA.right, greaterThan(20));
      expect(rectB.left, lessThan(40));
      expect(rectB.right, greaterThan(60));
    });

    test('falls back to contour box when no strokes assigned', () {
      final List<List<Offset>> contours = <List<Offset>>[
        const [Offset.zero, Offset(10, 0), Offset(10, 10), Offset(0, 10)],
      ];

      final List<RotatedBoundingBox> boxes =
          ConvexHullCalculator.boundingBoxesForContours(
        contours,
        const [],
      );

      expect(boxes, hasLength(1));
      final Rect contourBox = _boundingBox(contours.single);
      final Rect result = _boundingBox(boxes.single.corners);
      expect(result.left, contourBox.left);
      expect(result.top, contourBox.top);
      expect(result.right, contourBox.right);
      expect(result.bottom, contourBox.bottom);
    });
  });
}
