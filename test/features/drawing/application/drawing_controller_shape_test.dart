import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DrawingController Shape Snapping', () {
    late DrawingController controller;

    setUp(() {
      controller = DrawingController();
    });

    test('trySnapToShape returns false when no stroke is active', () {
      expect(controller.trySnapToShape(), isFalse);
    });

    test('snaps to a line and locks subsequent updates', () {
      // 1. Draw a rough line
      controller.startStroke(
        DrawingPoint(position: const Offset(0, 0)),
        color: Colors.black,
        baseWidth: 5,
      );
      // Add points to simulate a line
      for (int i = 1; i <= 10; i++) {
        controller.updateStroke(DrawingPoint(
          position: Offset(i * 10.0, i * 10.0), // Perfect diagonal line
        ));
      }

      // 2. Try to snap
      final snapped = controller.trySnapToShape();
      expect(snapped, isTrue);

      // Verify points are simplified (just start and end for a line)
      expect(controller.currentStroke!.points.length, 2);
      final start = controller.currentStroke!.points.first.position;
      final end = controller.currentStroke!.points.last.position;
      expect(start, const Offset(0, 0));
      expect(end, const Offset(100, 100));

      // 3. Update stroke (simulate dragging the end point)
      // The controller logic finds the closest vertex to the last point.
      // Last point was (100, 100), so index 1 (end) should be active.

      // Move to (150, 150)
      controller.updateStroke(DrawingPoint(position: const Offset(150, 150)));

      // Verify the line is updated
      expect(controller.currentStroke!.points.length, 2);
      expect(controller.currentStroke!.points.first.position, const Offset(0, 0)); // Start remains
      expect(controller.currentStroke!.points.last.position, const Offset(150, 150)); // End moved
    });

    test('snaps to a rectangle and locks updates', () {
      // 1. Draw a rough rectangle
      controller.startStroke(
        DrawingPoint(position: const Offset(0, 0)),
        color: Colors.blue,
        baseWidth: 5,
      );

      final vertices = [
        const Offset(0, 0),
        const Offset(100, 0),
        const Offset(100, 50),
        const Offset(0, 50),
        const Offset(0, 0),
      ];

      // Interpolate lines
      for (int i = 0; i < vertices.length - 1; i++) {
        final start = vertices[i];
        final end = vertices[i+1];
        for(int j=1; j<=5; j++) {
           controller.updateStroke(DrawingPoint(
             position: Offset.lerp(start, end, j/5)!,
           ));
        }
      }

      // 2. Try to snap
      final snapped = controller.trySnapToShape();
      expect(snapped, isTrue);

      // Verify it is a rectangle (5 points because start/end are duplicated in generated points usually, or 4 lines)
      // ShapeRecognizer.generateRectPoints generates 5 points (closed loop)
      expect(controller.currentStroke!.points.length, 5);

      // 3. Update stroke (resize)
      // Last point was (0,0). Closest corner in the recognized rect is (0,0).
      // The opposite corner is (100, 50).
      // If we drag (0,0) to (-10, -10), the new rect should be from (-10, -10) to (100, 50).

      controller.updateStroke(DrawingPoint(position: const Offset(-10, -10)));

      final points = controller.currentStroke!.points;
      // Check bounds of the new points
      final xValues = points.map((p) => p.position.dx).toList();
      final yValues = points.map((p) => p.position.dy).toList();

      expect(xValues.reduce((a, b) => a < b ? a : b), closeTo(-10, 0.1));
      expect(xValues.reduce((a, b) => a > b ? a : b), closeTo(100, 0.1));
      expect(yValues.reduce((a, b) => a < b ? a : b), closeTo(-10, 0.1));
      expect(yValues.reduce((a, b) => a > b ? a : b), closeTo(50, 0.1));
    });

    test('endStroke resets shape locking', () async {
       // Start and snap a line
      controller.startStroke(
        DrawingPoint(position: const Offset(0, 0)),
        color: Colors.black,
        baseWidth: 5,
      );
      controller.updateStroke(DrawingPoint(position: const Offset(100, 100)));

      // Force snap logic manually if needed, or rely on trySnapToShape which needs good data
      // Let's just trust trySnapToShape works as proven above
      controller.trySnapToShape(tolerance: 1000); // High tolerance to ensure snap

      await controller.endStroke();

      // Start new stroke
      controller.startStroke(
        DrawingPoint(position: const Offset(200, 200)),
        color: Colors.red,
        baseWidth: 5,
      );

      // Update should NOT be constrained by previous lock
      controller.updateStroke(DrawingPoint(position: const Offset(210, 210)));

      expect(controller.currentStroke!.points.length, 2);
      // If it was still locked to the previous line logic, points would look different or it would try to update vertices index
    });
  });
}
