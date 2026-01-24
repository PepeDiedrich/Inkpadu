import 'dart:math' as math;
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Canvas Height Calculation Benchmark', () {
    late List<Stroke> strokes;

    setUp(() {
      // Create 1000 strokes with 100 points each
      strokes = List.generate(
        1000,
        (i) => Stroke(
          points: List.generate(
            100,
            (j) => DrawingPoint(position: Offset(100.0, 100.0 + i + j)),
          ),
        ),
      );
    });

    double calculateHeightIterative(List<Stroke> strokes) {
      var maxY = 0.0;
      for (final stroke in strokes) {
        for (final point in stroke.points) {
          final y = point.position.dy;
          if (y > maxY) {
            maxY = y;
          }
        }
      }
      return math.max(1600.0, maxY + 600.0);
    }

    double calculateHeightOptimized(List<Stroke> strokes) {
      var maxY = 0.0;
      for (final stroke in strokes) {
        final y = stroke.boundingBox.bottom;
        if (y > maxY) {
          maxY = y;
        }
      }
      return math.max(1600.0, maxY + 600.0);
    }

    test('Iterative approach performance', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        calculateHeightIterative(strokes);
      }
      stopwatch.stop();
      debugPrint('Iterative approach (100 runs): ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Optimized approach performance', () {
      // Warm up caching
      calculateHeightOptimized(strokes);

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        calculateHeightOptimized(strokes);
      }
      stopwatch.stop();
      debugPrint('Optimized approach (100 runs): ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
