import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart'; // For Offset
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Benchmark canvas height calculation', () {
    // 1. Setup: Generate 100 strokes with 1000 points each
    const int strokeCount = 100;
    const int pointsPerStroke = 1000;
    final List<Stroke> strokes = [];

    for (int i = 0; i < strokeCount; i++) {
      final List<DrawingPoint> points = [];
      for (int j = 0; j < pointsPerStroke; j++) {
        points.add(
          DrawingPoint(
            position: Offset(
              (i * 10 + j).toDouble(),
              (i * 100 + j).toDouble(), // Increasing Y
            ),
            pressure: 0.5,
          ),
        );
      }
      strokes.add(Stroke(points: points));
    }

    // Warmup
    _calculateHeightNaive(strokes);
    _calculateHeightOptimized(strokes);

    // 2. Measure Naive (O(N*M))
    final stopwatchNaive = Stopwatch()..start();
    final heightNaive = _calculateHeightNaive(strokes);
    stopwatchNaive.stop();
    final timeNaive = stopwatchNaive.elapsedMicroseconds;

    // 3. Measure Optimized (O(N))
    final stopwatchOpt = Stopwatch()..start();
    final heightOpt = _calculateHeightOptimized(strokes);
    stopwatchOpt.stop();
    final timeOpt = stopwatchOpt.elapsedMicroseconds;

    // 4. Verification
    expect(heightNaive, equals(heightOpt), reason: 'Heights should be identical');
    debugPrint('Naive: ${timeNaive}µs');
    debugPrint('Optimized: ${timeOpt}µs');
    debugPrint('Speedup: ${(timeNaive / timeOpt).toStringAsFixed(1)}x');

    // Expect significant speedup (e.g., > 10x)
    if (timeOpt > 0) {
      expect(timeNaive / timeOpt, greaterThan(10));
    } else {
      expect(timeNaive, greaterThan(0));
    }
  });
}

double _calculateHeightNaive(List<Stroke> strokes) {
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

double _calculateHeightOptimized(List<Stroke> strokes) {
  var maxY = 0.0;
  for (final stroke in strokes) {
    final y = stroke.boundingBox.bottom;
    if (y > maxY) {
      maxY = y;
    }
  }
  return maxY;
}
