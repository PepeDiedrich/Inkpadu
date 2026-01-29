import 'dart:math' as math;
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Benchmark _requiredCanvasHeightForStrokes', () {
    // 1. Setup Data
    const int strokeCount = 1000;
    const int pointsPerStroke = 100;
    final List<Stroke> strokes = [];

    for (int i = 0; i < strokeCount; i++) {
      final points = <DrawingPoint>[];
      for (int j = 0; j < pointsPerStroke; j++) {
        points.add(DrawingPoint(
          position: Offset(j.toDouble(), i * 10.0 + j),
          pressure: 0.5,
        ));
      }
      strokes.add(Stroke(points: points));
    }

    const double initialCanvasHeight = 1600;
    const double canvasBottomPadding = 600;

    // 2. Baseline (Current Implementation)
    final stopwatchBaseline = Stopwatch()..start();

    var maxY_baseline = 0.0;
    for (final stroke in strokes) {
      for (final point in stroke.points) {
        final y = point.position.dy;
        if (y > maxY_baseline) {
          maxY_baseline = y;
        }
      }
    }
    final baselineResult = math.max(
      initialCanvasHeight,
      maxY_baseline + canvasBottomPadding,
    );

    stopwatchBaseline.stop();
    print('Baseline (O(S*P)): ${stopwatchBaseline.elapsedMicroseconds} µs');

    // 3. Optimization (Using boundingBox)
    // Note: The first time we access boundingBox, it will compute it (O(P)).
    // To simulate steady state (cached), we access it once before timing,
    // OR we accept that the first run includes caching overhead.
    // However, in the real app, we check height after a stroke is added.
    // Old strokes are cached, new stroke is not.
    // So to be fair, we should pre-warm the cache for all but one stroke?
    // Or just measure "re-calculating from scratch" vs "using cached".

    // Let's pre-warm to show the benefit of caching for existing strokes.
    for (final stroke in strokes) {
      // ignore: unused_local_variable
      final _ = stroke.boundingBox;
    }

    final stopwatchOpt = Stopwatch()..start();

    var maxY_opt = 0.0;
    for (final stroke in strokes) {
      final bottom = stroke.boundingBox.bottom;
      if (bottom > maxY_opt) {
        maxY_opt = bottom;
      }
    }
    final optResult = math.max(
      initialCanvasHeight,
      maxY_opt + canvasBottomPadding,
    );

    stopwatchOpt.stop();
    print('Optimization (O(S) cached): ${stopwatchOpt.elapsedMicroseconds} µs');

    expect(optResult, equals(baselineResult));
  });
}
