import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Benchmark NoteThumbnail bounding box calculation', () {
    // Generate a heavy page: 100 strokes, each with 100 points
    final strokes = List.generate(
      100,
      (i) => Stroke(
        points: List.generate(
          100,
          (j) => DrawingPoint(position: Offset(i * 10.0 + j, i * 10.0 + j)),
        ),
      ),
    );

    // Warm up the cache for Stroke.boundingBox (simulation of previous renders)
    for (final stroke in strokes) {
      // ignore: unused_local_variable
      final _ = stroke.boundingBox;
    }

    // Benchmark Old Approach (Iterating Points)
    final stopwatchOld = Stopwatch()..start();
    for (int run = 0; run < 100; run++) {
      double minX = double.infinity;
      double minY = double.infinity;
      double maxX = double.negativeInfinity;
      double maxY = double.negativeInfinity;

      for (final stroke in strokes) {
        for (final point in stroke.points) {
          if (point.position.dx < minX) minX = point.position.dx;
          if (point.position.dy < minY) minY = point.position.dy;
          if (point.position.dx > maxX) maxX = point.position.dx;
          if (point.position.dy > maxY) maxY = point.position.dy;
        }
      }
    }
    stopwatchOld.stop();
    // ignore: avoid_print
    print('Old Approach (100 runs): ${stopwatchOld.elapsedMicroseconds} µs');

    // Benchmark New Approach (Using Stroke.boundingBox)
    final stopwatchNew = Stopwatch()..start();
    for (int run = 0; run < 100; run++) {
      double minX = double.infinity;
      double minY = double.infinity;
      double maxX = double.negativeInfinity;
      double maxY = double.negativeInfinity;

      for (final stroke in strokes) {
        final rect = stroke.boundingBox;
        if (rect.left < minX) minX = rect.left;
        if (rect.top < minY) minY = rect.top;
        if (rect.right > maxX) maxX = rect.right;
        if (rect.bottom > maxY) maxY = rect.bottom;
      }
    }
    stopwatchNew.stop();
    // ignore: avoid_print
    print('New Approach (100 runs): ${stopwatchNew.elapsedMicroseconds} µs');

    expect(
      stopwatchNew.elapsedMicroseconds,
      lessThan(stopwatchOld.elapsedMicroseconds),
    );
  });
}
