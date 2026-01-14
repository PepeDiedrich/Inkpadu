import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';

void main() {
  test('Benchmark: Canvas height calculation performance', () {
    // Setup: Create 100 strokes with 1000 points each
    final strokes = List.generate(100, (i) {
      return Stroke(
        points: List.generate(1000, (j) {
          return DrawingPoint(
            position: Offset(j.toDouble(), i * 10.0 + math.sin(j) * 5),
            pressure: 0.5,
          );
        }),
      );
    });

    final stopwatch = Stopwatch();

    // Old Method
    stopwatch.start();
    var maxY_old = 0.0;
    for (int k = 0; k < 10; k++) {
      maxY_old = 0.0;
      for (final stroke in strokes) {
        for (final point in stroke.points) {
          final y = point.position.dy;
          if (y > maxY_old) {
            maxY_old = y;
          }
        }
      }
    }
    stopwatch.stop();
    final oldTime = stopwatch.elapsedMicroseconds;
    debugPrint('Old method time (10 iterations): ${oldTime}us');

    // New Method
    stopwatch.reset();
    stopwatch.start();
    var maxY_new = 0.0;
    for (int k = 0; k < 10; k++) {
       maxY_new = 0.0;
      for (final stroke in strokes) {
        final y = stroke.boundingBox.bottom;
        if (y > maxY_new) {
          maxY_new = y;
        }
      }
    }
    stopwatch.stop();
    final newTime = stopwatch.elapsedMicroseconds;
    debugPrint('New method time (10 iterations): ${newTime}us');

    // Correct expectation calculation:
    // Last stroke is index 99.
    // i = 99.
    // Base Y = 99 * 10.0 = 990.0.
    // Max sine wave is +5.
    // Max Y approx 995.0.

    // Actually finding the max manually to be sure.
    var realMax = 0.0;
    for (final stroke in strokes) {
      for (final point in stroke.points) {
        if (point.position.dy > realMax) realMax = point.position.dy;
      }
    }

    expect(maxY_new, closeTo(realMax, 0.001));
    expect(maxY_old, closeTo(realMax, 0.001));

    expect(newTime, lessThan(oldTime));
    debugPrint('Improvement: ${(oldTime / newTime).toStringAsFixed(1)}x faster');
  });
}
