import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/application/shape_recognizer.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DrawingController Shape Snapping', () {
    late DrawingController controller;

    setUp(() {
      controller = DrawingController();
    });

    test('trySnapToShape detects a line and locks the stroke', () {
      // Draw a roughly straight line
      final start = DrawingPoint(position: const Offset(0, 0));
      controller.startStroke(start, color: Colors.black, baseWidth: 5);

      for (var i = 1; i <= 10; i++) {
        controller.updateStroke(DrawingPoint(position: Offset(i * 10.0, i * 0.5))); // Slight deviation
      }

      // Attempt to snap
      final snapped = controller.trySnapToShape();

      expect(snapped, isTrue);
      // We can't easily access private _isLockedToShape, but we can verify behavior
      // A locked line should only have 2 points (start and end) after snapping?
      // Let's check ShapeRecognizer behavior via the controller result.
      // The implementation uses ShapeRecognizer.recognizeShape which returns corrected points.
      // For a line, it usually returns [start, end].

      final currentPoints = controller.currentStroke!.points;
      expect(currentPoints.length, 2);
      expect(currentPoints.first.position, const Offset(0,0));
      // The end point should be projected/corrected.
    });

    test('updateStroke modifies only endpoint when locked to a line', () {
      // 1. Start and draw a line
      controller.startStroke(
          DrawingPoint(position: const Offset(0, 0)),
          color: Colors.black,
          baseWidth: 5
      );
      controller.updateStroke(DrawingPoint(position: const Offset(100, 0)));

      // 2. Force snap (assuming the above is straight enough, or we can cheat if we could mock ShapeRecognizer,
      // but here we rely on the real one. A perfect horizontal line should snap.)
      final snapped = controller.trySnapToShape();
      expect(snapped, isTrue, reason: "Perfect line should snap");

      // 3. Update stroke with a new point
      final newPoint = DrawingPoint(position: const Offset(120, 50));
      controller.updateStroke(newPoint);

      // 4. Verify that we still have 2 points and the last one is the newPoint
      final points = controller.currentStroke!.points;
      expect(points.length, 2);
      expect(points.last, equals(newPoint));
    });

    test('endStroke does not simplify if shape was locked', () async {
      // 1. Draw and snap a line
      controller.startStroke(
          DrawingPoint(position: const Offset(0, 0)),
          color: Colors.black,
          baseWidth: 5
      );
      controller.updateStroke(DrawingPoint(position: const Offset(100, 0)));
      controller.trySnapToShape();

      // 2. End stroke
      await controller.endStroke();

      // 3. Verify the stored stroke.
      // If simplified, it might still have 2 points, but the key is that
      // the controller logic `if (simplify && !wasLocked)` skips simplification.
      // We can't easily verify the implementation path without mocks,
      // but we can verify the result is preserved.

      expect(controller.strokes.length, 1);
      final storedStroke = controller.strokes.first;
      // It should be a line (2 points)
      expect(storedStroke.points.length, 2);
    });

    test('trySnapToShape fails for complex scribble', () {
       controller.startStroke(
          DrawingPoint(position: const Offset(0, 0)),
          color: Colors.black,
          baseWidth: 5
      );
      // Zig-zag
      controller.updateStroke(DrawingPoint(position: const Offset(10, 10)));
      controller.updateStroke(DrawingPoint(position: const Offset(20, 0)));
      controller.updateStroke(DrawingPoint(position: const Offset(30, 10)));

      final snapped = controller.trySnapToShape(tolerance: 1.0); // Low tolerance
      expect(snapped, isFalse);
    });
  });
}
