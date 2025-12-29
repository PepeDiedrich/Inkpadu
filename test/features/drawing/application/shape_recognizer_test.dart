import 'package:flutter_test/flutter_test.dart';
import 'package:ai_handwriting_app/features/drawing/application/shape_recognizer.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';

void main() {
  group('ShapeRecognizer', () {
    test('recognizes a perfect line', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0), pressure: 1.0),
        DrawingPoint(position: const Offset(10, 10), pressure: 1.0),
        DrawingPoint(position: const Offset(20, 20), pressure: 1.0),
        DrawingPoint(position: const Offset(30, 30), pressure: 1.0),
      ];

      final match = ShapeRecognizer.recognizeShape(points, 2.0);
      expect(match, isNotNull);
      expect(match!.type, ShapeType.line);
      expect(match.correctedPoints.length, 2);
      expect(match.correctedPoints.first.position, const Offset(0, 0));
      expect(match.correctedPoints.last.position, const Offset(30, 30));
    });

    test('recognizes a somewhat straight line within tolerance', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0), pressure: 1.0),
        DrawingPoint(position: const Offset(10, 12), pressure: 1.0), // slightly off
        DrawingPoint(position: const Offset(20, 18), pressure: 1.0), // slightly off
        DrawingPoint(position: const Offset(30, 30), pressure: 1.0),
      ];

      // Deviation is roughly 2.0
      // sqrt(2*2) ~ 1.414 distance from line y=x?
      // (10,12) -> proj on y=x is (11,11). dist sqrt(1+1) = 1.414.

      final match = ShapeRecognizer.recognizeShape(points, 3.0);
      expect(match, isNotNull);
      expect(match!.type, ShapeType.line);
    });

    test('rejects a curve', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0), pressure: 1.0),
        DrawingPoint(position: const Offset(10, 20), pressure: 1.0),
        DrawingPoint(position: const Offset(20, 20), pressure: 1.0),
        DrawingPoint(position: const Offset(30, 0), pressure: 1.0),
      ];

      final match = ShapeRecognizer.recognizeShape(points, 5.0);
      expect(match, isNull);
    });

    test('rejects insufficient points', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0), pressure: 1.0),
      ];
      final match = ShapeRecognizer.recognizeShape(points, 5.0);
      expect(match, isNull);
    });

    test('handles vertical line', () {
       final points = [
        DrawingPoint(position: const Offset(10, 0), pressure: 1.0),
        DrawingPoint(position: const Offset(11, 10), pressure: 1.0),
        DrawingPoint(position: const Offset(10, 20), pressure: 1.0),
      ];
      final match = ShapeRecognizer.recognizeShape(points, 2.0);
      expect(match, isNotNull);
      expect(match!.type, ShapeType.line);
    });
  });
}
