import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';

void main() {
  test('Benchmark: Canvas height calculation', () {
    // 1. Setup Data
    const int strokeCount = 1000;
    const int pointsPerStroke = 100;
    final List<Stroke> strokes = [];

    for (int i = 0; i < strokeCount; i++) {
      final List<DrawingPoint> points = [];
      for (int j = 0; j < pointsPerStroke; j++) {
        points.add(
          DrawingPoint(
            position: Offset(j.toDouble(), (i * 10 + j).toDouble()),
            pressure: 0.5,
          ),
        );
      }
      strokes.add(Stroke(points: points));
    }

    // 2. Old Implementation (O(TotalPoints))
    final stopwatchOld = Stopwatch()..start();
    double maxYOld = 0.0;
    for (final stroke in strokes) {
      for (final point in stroke.points) {
        final y = point.position.dy;
        if (y > maxYOld) {
          maxYOld = y;
        }
      }
    }
    stopwatchOld.stop();
    print('Old Implementation Time: ${stopwatchOld.elapsedMicroseconds} µs');

    // 3. New Implementation (O(Strokes))
    // We access boundingBox once before timing to simulate steady state (cache populated)
    // or include it to see cold start performance.
    // The optimization is most effective when cache is populated or when stroke count is high.
    // Let's measure cold start first (first access).

    final stopwatchNew = Stopwatch()..start();
    double maxYNew = 0.0;
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final y = stroke.boundingBox.bottom;
      if (y > maxYNew) {
        maxYNew = y;
      }
    }
    stopwatchNew.stop();
    print(
      'New Implementation Time (Cold): ${stopwatchNew.elapsedMicroseconds} µs',
    );

    expect(maxYNew, equals(maxYOld));

    // 4. New Implementation (Warm - Cached)
    final stopwatchNewWarm = Stopwatch()..start();
    double maxYNewWarm = 0.0;
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final y = stroke.boundingBox.bottom;
      if (y > maxYNewWarm) {
        maxYNewWarm = y;
      }
    }
    stopwatchNewWarm.stop();
    print(
      'New Implementation Time (Warm): ${stopwatchNewWarm.elapsedMicroseconds} µs',
    );

    expect(maxYNewWarm, equals(maxYOld));
  });
}
