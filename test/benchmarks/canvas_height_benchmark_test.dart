import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canvas Height Calculation Benchmark', () {
    late List<Stroke> strokes;

    setUp(() {
      // Create 1000 strokes, each with 100 points
      strokes = List.generate(1000, (i) => Stroke(
          points: List.generate(100, (j) => DrawingPoint(
              position: Offset(j.toDouble(), i * 10.0 + j), // Spreading downwards
            ),
          ),
        ),
      );
    });

    double slowCalculation(List<Stroke> strokes) {
      var maxY = 0.0;
      for (final stroke in strokes) {
        for (final point in stroke.points) {
          final y = point.position.dy;
          if (y > maxY) {
            maxY = y;
          }
        }
      }
      return maxY;
    }

    double fastCalculation(List<Stroke> strokes) {
      var maxY = 0.0;
      for (final stroke in strokes) {
        if (stroke.points.isEmpty) continue;
        final y = stroke.boundingBox.bottom;
        if (y > maxY) {
          maxY = y;
        }
      }
      return maxY;
    }

    test('Benchmark comparison', () {
      final stopwatch = Stopwatch()..start();

      // Warmup and cache population
      fastCalculation(strokes);

      // Run slow method
      stopwatch.reset();
      for (int i = 0; i < 100; i++) {
        slowCalculation(strokes);
      }
      final slowTime = stopwatch.elapsedMicroseconds;
      debugPrint('Slow method (100 runs): ${slowTime / 1000} ms');

      // Run fast method (cached)
      stopwatch.reset();
      for (int i = 0; i < 100; i++) {
        fastCalculation(strokes);
      }
      final fastTime = stopwatch.elapsedMicroseconds;
      debugPrint('Fast method (100 runs, cached): ${fastTime / 1000} ms');

      expect(fastTime, lessThan(slowTime));
      debugPrint('Improvement: ${(slowTime / fastTime).toStringAsFixed(1)}x faster');
    });
  });
}
