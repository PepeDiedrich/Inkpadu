import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canvas Height Calculation Benchmark', () {
    late List<Stroke> strokes;
    const int strokeCount = 1000;
    const int pointsPerStroke = 100;

    setUpAll(() {
      strokes = List.generate(
        strokeCount,
        (i) => Stroke(
          points: List.generate(
            pointsPerStroke,
            (j) => DrawingPoint(
              position: Offset(
                i.toDouble() + j,
                (i * 10 + j).toDouble(), // Increasing Y
              ),
            ),
          ),
        ),
      );
    });

    test('Benchmark: Iterating all points (Old way)', () {
      final stopwatch = Stopwatch()..start();

      var maxY = 0.0;
      for (final stroke in strokes) {
        for (final point in stroke.points) {
          final y = point.position.dy;
          if (y > maxY) {
            maxY = y;
          }
        }
      }

      stopwatch.stop();
      debugPrint('Iterating points took: ${stopwatch.elapsedMicroseconds}us');

      // Verification
      final expectedMaxY =
          (strokeCount - 1) * 10 + (pointsPerStroke - 1).toDouble();
      expect(maxY, expectedMaxY);
    });

    test('Benchmark: Using cached boundingBox (New way)', () {
      // Warm up cache
      for (final stroke in strokes) {
        // Accessing boundingBox caches it
        final _ = stroke.boundingBox;
      }

      final stopwatch = Stopwatch()..start();

      var maxY = 0.0;
      for (final stroke in strokes) {
        if (stroke.points.isNotEmpty) {
          final bottom = stroke.boundingBox.bottom;
          if (bottom > maxY) {
            maxY = bottom;
          }
        }
      }

      stopwatch.stop();
      debugPrint('Using boundingBox took: ${stopwatch.elapsedMicroseconds}us');

      // Verification
      final expectedMaxY =
          (strokeCount - 1) * 10 + (pointsPerStroke - 1).toDouble();
      expect(maxY, expectedMaxY);
    });
  });
}
