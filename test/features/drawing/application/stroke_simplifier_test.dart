import 'package:ai_handwriting_app/features/drawing/application/stroke_simplifier.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('simplifyStrokePoints (RDP Algorithm)', () {
    test('returns empty list for empty input', () {
      final points = <DrawingPoint>[];
      final result = simplifyStrokePoints(points);
      expect(result, isEmpty);
    });

    test('returns original list for 1 point', () {
      final points = [DrawingPoint(position: const Offset(0, 0))];
      final result = simplifyStrokePoints(points);
      expect(result, hasLength(1));
      expect(result.first.position, const Offset(0, 0));
    });

    test('returns original list for 2 points', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(10, 10)),
      ];
      final result = simplifyStrokePoints(points);
      expect(result, hasLength(2));
      expect(result[0].position, const Offset(0, 0));
      expect(result[1].position, const Offset(10, 10));
    });

    test('removes middle point if it is perfectly on the line', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(5, 5)), // Middle point on line
        DrawingPoint(position: const Offset(10, 10)),
      ];
      // Default tolerance is 1.0, distance is 0.
      final result = simplifyStrokePoints(points);
      expect(result, hasLength(2));
      expect(result.first.position, const Offset(0, 0));
      expect(result.last.position, const Offset(10, 10));
    });

    test('keeps middle point if it is outside tolerance', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(5, 10)), // Far away
        DrawingPoint(position: const Offset(10, 0)),
      ];
      // Distance is 10, tolerance is 1.0
      final result = simplifyStrokePoints(points);
      expect(result, hasLength(3));
    });

    test('removes points within specific tolerance', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(5, 0.5)), // 0.5 away
        DrawingPoint(position: const Offset(10, 0)),
      ];
      // Tolerance 1.0 > 0.5 -> remove
      final result = simplifyStrokePoints(points);
      expect(result, hasLength(2));
    });

    test('keeps points outside specific tolerance', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(5, 1.5)), // 1.5 away
        DrawingPoint(position: const Offset(10, 0)),
      ];
      // Tolerance 1.0 < 1.5 -> keep
      final result = simplifyStrokePoints(points);
      expect(result, hasLength(3));
    });

    test('handles negative tolerance as 0 (strict)', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(5, 0.001)), // Very close
        DrawingPoint(position: const Offset(10, 0)),
      ];
      // Tolerance -1 -> 0. Everything not strictly on line is kept.
      final result = simplifyStrokePoints(points, tolerance: -1.0);
      expect(result, hasLength(3));
    });

    test('handles zigzag pattern correctly', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(5, 5)),
        DrawingPoint(position: const Offset(10, 0)),
        DrawingPoint(position: const Offset(15, 5)),
        DrawingPoint(position: const Offset(20, 0)),
      ];
      // All peaks are far from baseline (0,0)->(20,0) but local recursion handles them.
      // Distances are 5.0.
      final result = simplifyStrokePoints(points);
      expect(result, hasLength(5));
    });

    test('handles NaN tolerance as 0', () {
       final points = [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(5, 0.1)),
        DrawingPoint(position: const Offset(10, 0)),
      ];
      final result = simplifyStrokePoints(points, tolerance: double.nan);
      expect(result, hasLength(3));
    });
  });

  group('simplifyStroke', () {
    test('preserves stroke properties', () {
      final original = Stroke(
        points: [
          DrawingPoint(position: const Offset(0, 0)),
          DrawingPoint(position: const Offset(5, 0)),
          DrawingPoint(position: const Offset(10, 0)),
        ],
        color: Colors.red,
        baseWidth: 5.0,
        isHighlighter: true,
      );

      final simplified = simplifyStroke(original);

      expect(simplified.points, hasLength(2)); // Middle point removed
      expect(simplified.color, Colors.red);
      expect(simplified.baseWidth, 5.0);
      expect(simplified.isHighlighter, isTrue);
      expect(simplified.id, original.id);
    });
  });
}
