import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';

// Copy of the method to be benchmarked (as it exists in the codebase before optimization)
// We copy it here because it is a private method in DrawingCanvas state.
double _requiredCanvasHeightForStrokes_Old(List<Stroke> strokes, double initialHeight, double padding) {
  var maxY = 0.0;
  for (final stroke in strokes) {
    for (final point in stroke.points) {
      final y = point.position.dy;
      if (y > maxY) {
        maxY = y;
      }
    }
  }
  return (maxY + padding > initialHeight) ? maxY + padding : initialHeight;
}

// Optimized version
double _requiredCanvasHeightForStrokes_New(List<Stroke> strokes, double initialHeight, double padding) {
  var maxY = 0.0;
  for (final stroke in strokes) {
    if (stroke.boundingBox.bottom > maxY) {
      maxY = stroke.boundingBox.bottom;
    }
  }
  return (maxY + padding > initialHeight) ? maxY + padding : initialHeight;
}

void main() {
  test('Benchmark: _requiredCanvasHeightForStrokes performance', () {
    // 1. Setup: Create a large number of strokes with many points
    final strokes = <Stroke>[];
    const int numStrokes = 1000;
    const int pointsPerStroke = 100;

    for (int i = 0; i < numStrokes; i++) {
      final points = <DrawingPoint>[];
      for (int j = 0; j < pointsPerStroke; j++) {
        points.add(DrawingPoint(position: Offset(i * 10.0 + j, i * 100.0 + j)));
      }
      strokes.add(Stroke(points: points));
    }

    // Warmup
    _requiredCanvasHeightForStrokes_Old(strokes, 1600, 600);
    _requiredCanvasHeightForStrokes_New(strokes, 1600, 600);

    // 2. Measure Old Implementation
    final stopwatchOld = Stopwatch()..start();
    for (int i = 0; i < 100; i++) {
      _requiredCanvasHeightForStrokes_Old(strokes, 1600, 600);
    }
    stopwatchOld.stop();
    print('Old implementation (100 runs): ${stopwatchOld.elapsedMilliseconds} ms');

    // 3. Measure New Implementation
    final stopwatchNew = Stopwatch()..start();
    for (int i = 0; i < 100; i++) {
      _requiredCanvasHeightForStrokes_New(strokes, 1600, 600);
    }
    stopwatchNew.stop();
    print('New implementation (100 runs): ${stopwatchNew.elapsedMilliseconds} ms');

    // 4. Assert improvement
    // We expect at least 10x improvement (100 points per stroke -> 1 bounding box access)
    // Note: First access to boundingBox is O(N), subsequent are O(1).
    // In this benchmark, we run it 100 times, so caching helps massively.
    // Even without caching (if we recreated strokes), O(N) points vs O(N) points is same,
    // but here we are reusing strokes, which mimics the app behavior (adding 1 stroke to 1000 existing ones).

    expect(stopwatchNew.elapsedMilliseconds, lessThan(stopwatchOld.elapsedMilliseconds));

    // Check correctness
    final heightOld = _requiredCanvasHeightForStrokes_Old(strokes, 1600, 600);
    final heightNew = _requiredCanvasHeightForStrokes_New(strokes, 1600, 600);
    expect(heightNew, equals(heightOld));
  });
}
