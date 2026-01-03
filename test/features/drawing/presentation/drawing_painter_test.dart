import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCanvas extends Mock implements Canvas {}

void main() {
  setUpAll(() {
    registerFallbackValue(Paint());
    registerFallbackValue(Offset.zero);
    registerFallbackValue(Path());
  });

  group('FinishedStrokesPainter', () {
    final stroke1 = Stroke(
      points: [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(10, 10)),
      ],
      // color default is black, removed redundant
      baseWidth: 2.0,
    );
    final stroke2 = Stroke(
      points: [
        DrawingPoint(position: const Offset(20, 20)),
        DrawingPoint(position: const Offset(30, 30)),
      ],
      color: Colors.red,
      baseWidth: 2.0,
    );

    test('shouldRepaint returns true when version changes', () {
      final painter1 = FinishedStrokesPainter(strokes: [stroke1], version: 1);
      final painter2 = FinishedStrokesPainter(strokes: [stroke1], version: 2);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('shouldRepaint returns false when version is same', () {
      final painter1 = FinishedStrokesPainter(strokes: [stroke1], version: 1);
      final painter2 = FinishedStrokesPainter(strokes: [stroke1], version: 1);

      expect(painter2.shouldRepaint(painter1), isFalse);
    });

    test('paint calls canvas.drawLine for each segment', () {
      final canvas = MockCanvas();
      final painter = FinishedStrokesPainter(strokes: [stroke1, stroke2], version: 1);

      painter.paint(canvas, const Size(100, 100));

      verify(() => canvas.drawLine(
            const Offset(0, 0),
            const Offset(10, 10),
            any(),
          )).called(1);
      verify(() => canvas.drawLine(
            const Offset(20, 20),
            const Offset(30, 30),
            any(),
          )).called(1);
    });

    test('paint handles empty strokes gracefully', () {
      final canvas = MockCanvas();
      final emptyStroke = Stroke(
        points: [],
        // color default is black, removed redundant
        baseWidth: 2.0,
      );
      final painter = FinishedStrokesPainter(strokes: [emptyStroke], version: 1);

      painter.paint(canvas, const Size(100, 100));

      verifyNever(() => canvas.drawLine(any(), any(), any()));
    });
  });

  group('CurrentStrokePainter', () {
    final stroke = Stroke(
      points: [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(10, 10)),
      ],
      color: Colors.blue,
      baseWidth: 2.0,
    );

    test('shouldRepaint returns true when currentStroke changes', () {
      final painter1 = CurrentStrokePainter(currentStroke: stroke, pointCount: 2);
      final painter2 = CurrentStrokePainter(currentStroke: null, pointCount: 0);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('shouldRepaint returns true when pointCount changes', () {
      final painter1 = CurrentStrokePainter(currentStroke: stroke, pointCount: 2);
      final painter2 = CurrentStrokePainter(currentStroke: stroke, pointCount: 3);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('shouldRepaint returns false when unchanged', () {
      final painter1 = CurrentStrokePainter(currentStroke: stroke, pointCount: 2);
      final painter2 = CurrentStrokePainter(currentStroke: stroke, pointCount: 2);

      expect(painter2.shouldRepaint(painter1), isFalse);
    });

    test('paint calls canvas.drawLine', () {
      final canvas = MockCanvas();
      final painter = CurrentStrokePainter(currentStroke: stroke, pointCount: 2);

      painter.paint(canvas, const Size(100, 100));

      verify(() => canvas.drawLine(
            const Offset(0, 0),
            const Offset(10, 10),
            any(),
          )).called(1);
    });

    test('paint does nothing if currentStroke is null', () {
      final canvas = MockCanvas();
      final painter = CurrentStrokePainter(currentStroke: null, pointCount: 0);

      painter.paint(canvas, const Size(100, 100));

      verifyNever(() => canvas.drawLine(any(), any(), any()));
    });
  });

  group('ConvexHullsPainter', () {
    final hull = [const Offset(0, 0), const Offset(10, 0), const Offset(0, 10)];
    final box = RotatedBoundingBox(
      corners: const [Offset(0, 0), Offset(10, 0), Offset(10, 10), Offset(0, 10)],
      angle: 0,
      width: 10,
      height: 10,
    );

    test('shouldRepaint returns true when hulls change', () {
      const painter1 = ConvexHullsPainter(hulls: [], boundingBoxes: []);
      final painter2 = ConvexHullsPainter(hulls: [hull], boundingBoxes: []);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('shouldRepaint returns true when boundingBoxes change', () {
      const painter1 = ConvexHullsPainter(hulls: [], boundingBoxes: []);
      final painter2 = ConvexHullsPainter(hulls: [], boundingBoxes: [box]);

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('shouldRepaint returns false when unchanged', () {
      final hulls = [hull];
      final boxes = [box];

      final painter1 = ConvexHullsPainter(hulls: hulls, boundingBoxes: boxes);
      final painter2 = ConvexHullsPainter(hulls: hulls, boundingBoxes: boxes);

      expect(painter2.shouldRepaint(painter1), isFalse);
    });

    test('paint draws paths for hulls and boxes', () {
      final canvas = MockCanvas();
      final painter = ConvexHullsPainter(hulls: [hull], boundingBoxes: [box]);

      painter.paint(canvas, const Size(100, 100));

      // 2 calls for hull (fill and stroke) + 2 calls for box (fill and stroke)
      verify(() => canvas.drawPath(any(), any())).called(4);
    });

    test('paint handles zero size boxes', () {
       final canvas = MockCanvas();
       // Hull with < 2 points is invalid
       final invalidHull = [const Offset(0, 0)];

       final zeroBox = RotatedBoundingBox(
         corners: const [Offset.zero, Offset.zero, Offset.zero, Offset.zero],
         angle: 0,
         width: 0,
         height: 0,
       );

       final painter = ConvexHullsPainter(hulls: [invalidHull], boundingBoxes: [zeroBox]);

       painter.paint(canvas, const Size(100, 100));

       // Hull is skipped (<2 points)
       // Box is drawn but not filled because width/height <= 0
       // So we expect 1 drawPath call (stroke only)
       verify(() => canvas.drawPath(any(), any())).called(1);
    });
  });
}
