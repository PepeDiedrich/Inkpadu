import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

void main() {
  test('Benchmark _requiredCanvasHeightForStrokes', () {
    // 1. Setup Data: 1000 strokes with 100 points each
    final strokes = List.generate(1000, (i) {
      return Stroke(
        points: List.generate(100, (j) {
          return DrawingPoint(
            position: Offset(j.toDouble(), i * 10.0 + j.toDouble()), // y increases
            pressure: 0.5,
          );
        }),
      );
    });

    const double initialCanvasHeight = 1600;
    const double canvasBottomPadding = 600;

    // 2. Measure Old Implementation (O(S*P))
    final stopwatchOld = Stopwatch()..start();
    var maxYOld = 0.0;
    for (final stroke in strokes) {
      for (final point in stroke.points) {
        final y = point.position.dy;
        if (y > maxYOld) {
          maxYOld = y;
        }
      }
    }
    final oldResult = math.max(
      initialCanvasHeight,
      maxYOld + canvasBottomPadding,
    );
    stopwatchOld.stop();
    print('Old Implementation Time: ${stopwatchOld.elapsedMicroseconds} µs');

    // 3. Measure New Implementation (O(S))
    final stopwatchNew = Stopwatch()..start();
    var maxYNew = 0.0;
    for (final stroke in strokes) {
      if (stroke.points.isNotEmpty) {
        // stroke.boundingBox is lazy, so first access computes it (O(P)).
        // But subsequent accesses (which happen on every frame/update) are O(1).
        // To simulate steady state, we access it once before timing?
        // Or we measure the "first access" cost vs "subsequent access" cost?
        // The optimization is most valuable for subsequent updates where strokes don't change but we re-calculate height.
        // But even for the first time, accessing boundingBox is O(P) once, then O(1).
        // The old implementation is O(P) ALWAYS.
        final bottom = stroke.boundingBox.bottom;
        if (bottom > maxYNew) {
          maxYNew = bottom;
        }
      }
    }
    final newResult = math.max(
      initialCanvasHeight,
      maxYNew + canvasBottomPadding,
    );
    stopwatchNew.stop();
    print('New Implementation Time: ${stopwatchNew.elapsedMicroseconds} µs');

    expect(oldResult, newResult);
    expect(stopwatchNew.elapsedMicroseconds, lessThan(stopwatchOld.elapsedMicroseconds));
  });

  test('Benchmark _requiredCanvasHeightForStrokes with pre-calculated bounds', () {
      // Setup Data
      final strokes = List.generate(1000, (i) {
        return Stroke(
          points: List.generate(100, (j) {
            return DrawingPoint(
              position: Offset(j.toDouble(), i * 10.0 + j.toDouble()),
              pressure: 0.5,
            );
          }),
        );
      });

      // Warm up caching
      for (final stroke in strokes) {
        // ignore: unused_local_variable
        final _ = stroke.boundingBox;
      }

      const double initialCanvasHeight = 1600;
      const double canvasBottomPadding = 600;

      // Measure Old Implementation
      final stopwatchOld = Stopwatch()..start();
      var maxYOld = 0.0;
      for (final stroke in strokes) {
        for (final point in stroke.points) {
          final y = point.position.dy;
          if (y > maxYOld) {
            maxYOld = y;
          }
        }
      }
      // ignore: unused_local_variable
      final oldResult = math.max(
        initialCanvasHeight,
        maxYOld + canvasBottomPadding,
      );
      stopwatchOld.stop();
      print('Old Implementation (Cached Scenario) Time: ${stopwatchOld.elapsedMicroseconds} µs');

      // Measure New Implementation
      final stopwatchNew = Stopwatch()..start();
      var maxYNew = 0.0;
      for (final stroke in strokes) {
        if (stroke.points.isNotEmpty) {
          final bottom = stroke.boundingBox.bottom;
          if (bottom > maxYNew) {
            maxYNew = bottom;
          }
        }
      }
      // ignore: unused_local_variable
      final newResult = math.max(
        initialCanvasHeight,
        maxYNew + canvasBottomPadding,
      );
      stopwatchNew.stop();
      print('New Implementation (Cached Scenario) Time: ${stopwatchNew.elapsedMicroseconds} µs');

      expect(stopwatchNew.elapsedMicroseconds, lessThan(stopwatchOld.elapsedMicroseconds / 10)); // Expect >10x speedup
  });
}
