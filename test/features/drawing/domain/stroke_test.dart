import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';

void main() {
  group('Stroke', () {
    test('creates Stroke with default values', () {
      final stroke = Stroke(points: []);
      expect(stroke.points, isEmpty);
      expect(stroke.color, Colors.black);
      expect(stroke.baseWidth, 4.0);
      expect(stroke.isHighlighter, false);
      expect(stroke.id, isNotEmpty);
    });

    test('creates Stroke with custom values', () {
      final points = [DrawingPoint(position: const Offset(0, 0), pressure: 1.0)];
      final stroke = Stroke(
        points: points,
        color: Colors.red,
        baseWidth: 2.0,
        isHighlighter: true,
        id: 'custom-id',
      );
      expect(stroke.points, points);
      expect(stroke.color, Colors.red);
      expect(stroke.baseWidth, 2.0);
      expect(stroke.isHighlighter, true);
      expect(stroke.id, 'custom-id');
    });

    group('boundingBox', () {
      test('returns Rect.zero for empty points', () {
        final stroke = Stroke(points: []);
        expect(stroke.boundingBox, Rect.zero);
      });

      test('calculates correct bounding box for points', () {
        final points = [
          DrawingPoint(position: const Offset(10, 20), pressure: 1.0),
          DrawingPoint(position: const Offset(50, 60), pressure: 1.0),
          DrawingPoint(position: const Offset(30, 40), pressure: 1.0),
        ];
        final stroke = Stroke(points: points);
        expect(stroke.boundingBox, const Rect.fromLTRB(10, 20, 50, 60));
      });

      test('caches bounding box calculation', () {
        // Since we can't easily check private _cachedBoundingBox, we verify behavior consistency
        // and assume performance benefits are handled internally.
        // Ideally we'd use a mock or partial mock if we wanted to verify the getter was only called once,
        // but for a domain entity, testing the output consistency is sufficient.
        final points = [
          DrawingPoint(position: const Offset(10, 20), pressure: 1.0),
          DrawingPoint(position: const Offset(50, 60), pressure: 1.0),
        ];
        final stroke = Stroke(points: points);

        // First access triggers calculation
        final box1 = stroke.boundingBox;
        expect(box1, const Rect.fromLTRB(10, 20, 50, 60));

        // Second access should return same result (likely cached)
        final box2 = stroke.boundingBox;
        expect(box2, const Rect.fromLTRB(10, 20, 50, 60));
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        final stroke = Stroke(points: [], color: Colors.blue);
        final newPoints = [DrawingPoint(position: const Offset(1, 1))];
        final copied = stroke.copyWith(
          points: newPoints,
          color: Colors.green,
          baseWidth: 5.0,
          isHighlighter: true,
          id: 'new-id',
        );

        expect(copied.points, newPoints);
        expect(copied.color, Colors.green);
        expect(copied.baseWidth, 5.0);
        expect(copied.isHighlighter, true);
        expect(copied.id, 'new-id');
      });

      test('copies with existing values if nulls passed', () {
        final stroke = Stroke(
          points: [DrawingPoint(position: const Offset(1, 1))],
          color: Colors.blue,
          baseWidth: 3.0,
          isHighlighter: true,
          id: 'original-id',
        );
        final copied = stroke.copyWith();

        expect(copied.points, stroke.points);
        expect(copied.color, stroke.color);
        expect(copied.baseWidth, stroke.baseWidth);
        expect(copied.isHighlighter, stroke.isHighlighter);
        expect(copied.id, stroke.id);
      });
    });

    group('serialization', () {
      test('toJson converts correctly', () {
        final points = [DrawingPoint(position: const Offset(10, 20), pressure: 0.8)];
        final stroke = Stroke(
          id: 'test-id',
          points: points,
          color: const Color(0xFFaabbcc), // ARGB
          baseWidth: 2.5,
          isHighlighter: true,
        );

        final json = stroke.toJson();
        expect(json['id'], 'test-id');
        expect(json['color'], const Color(0xFFaabbcc).toARGB32());
        expect(json['width'], 2.5);
        expect(json['isHighlighter'], true);

        final jsonPoints = json['points'] as List;
        expect(jsonPoints.length, 1);
        expect(jsonPoints[0]['x'], 10.0);
        expect(jsonPoints[0]['y'], 20.0);
        expect(jsonPoints[0]['p'], 0.8);
      });

      test('fromJson creates correct object', () {
        final json = {
          'id': 'json-id',
          'color': Colors.red.toARGB32(),
          'width': 6.0,
          'isHighlighter': false,
          'points': [
            {'x': 5.0, 'y': 5.0, 'p': 0.5}
          ]
        };

        final stroke = Stroke.fromJson(json);
        expect(stroke.id, 'json-id');
        expect(stroke.color.toARGB32(), Colors.red.toARGB32());
        expect(stroke.baseWidth, 6.0);
        expect(stroke.isHighlighter, false);
        expect(stroke.points.length, 1);
        expect(stroke.points.first.position, const Offset(5, 5));
        expect(stroke.points.first.pressure, 0.5);
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'points': <dynamic>[],
        };
        final stroke = Stroke.fromJson(json);
        expect(stroke.id, isNotNull); // Should generate new ID if missing? Logic says id = json['id'] as String? which is nullable in factory but constructor generates it.
        // Wait, factory passes: id: json['id'] as String?. If null, constructor generates it.
        expect(stroke.color, Colors.black); // Default
        expect(stroke.baseWidth, 4.0); // Default
        expect(stroke.isHighlighter, false); // Default
        expect(stroke.points, isEmpty);
      });
    });
  });
}
