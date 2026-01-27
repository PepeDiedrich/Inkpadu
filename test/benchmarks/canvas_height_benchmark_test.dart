import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Benchmark _requiredCanvasHeightForStrokes optimization (with caching)', () {
    // Setup: 1000 strokes, 100 points each
    final strokes = List.generate(1000, (i) => Stroke(
        points: List.generate(100, (j) => DrawingPoint(
            position: Offset(j.toDouble(), i * 10.0 + j),
          )),
      ));

    // Warmup (calculates caches) for "New" approach
    for (final stroke in strokes) {
      // Accessing boundingBox caches it
      final _ = stroke.boundingBox;
    }

    // Old implementation (O(N*M)) - Runs 10 times to simulate 10 frames of dragging
    final stopwatchOld = Stopwatch()..start();
    for (int i = 0; i < 10; i++) {
      var maxYOld = 0.0;
      for (final stroke in strokes) {
        for (final point in stroke.points) {
          final y = point.position.dy;
          if (y > maxYOld) {
            maxYOld = y;
          }
        }
      }
    }
    stopwatchOld.stop();
    debugPrint('Old implementation (10 runs): ${stopwatchOld.elapsedMicroseconds} µs');

    // New implementation (O(N)) - Runs 10 times
    final stopwatchNew = Stopwatch()..start();
    for (int i = 0; i < 10; i++) {
      var maxYNew = 0.0;
      for (final stroke in strokes) {
        final y = stroke.boundingBox.bottom;
        if (y > maxYNew) {
          maxYNew = y;
        }
      }
    }
    stopwatchNew.stop();
    debugPrint('New implementation (10 runs): ${stopwatchNew.elapsedMicroseconds} µs');

    expect(stopwatchNew.elapsedMicroseconds, lessThan(stopwatchOld.elapsedMicroseconds / 10)); // Should be >10x faster
  });
}
