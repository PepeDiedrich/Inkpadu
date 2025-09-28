import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DrawingController', () {
    late DrawingController controller;

    setUp(() {
      controller = DrawingController();
    });

    test('starts empty with no undo or redo possible', () {
      expect(controller.strokes, isEmpty);
      expect(controller.currentStroke, isNull);
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);
      expect(controller.strokesVersion, 0);
    });

    test('initialize clones provided strokes and resets redo stack', () {
      final initialStroke = Stroke(
        points: [
          DrawingPoint(position: const Offset(0, 0)),
          DrawingPoint(position: const Offset(10, 10)),
        ],
        color: Colors.blue,
        baseWidth: 5,
      );

      controller.initialize([initialStroke]);

      expect(controller.strokes, hasLength(1));
      expect(controller.strokes.first.points, equals(initialStroke.points));
      expect(controller.currentStroke, isNull);
      expect(controller.canUndo, isTrue);
      expect(controller.canRedo, isFalse);
      expect(controller.strokesVersion, 1);
    });

    test(
      'endStroke returns false for strokes with fewer than two points',
      () async {
        controller.startStroke(
          DrawingPoint(position: const Offset(0, 0)),
          color: Colors.red,
          baseWidth: 4,
        );

        final accepted = await controller.endStroke();

        expect(accepted, isFalse);
        expect(controller.strokes, isEmpty);
        expect(controller.canUndo, isFalse);
        expect(controller.strokesVersion, 0);
      },
    );

    test(
      'start, update and end stroke adds simplified stroke and clears redo stack',
      () async {
        final notifications = <void>[];
        controller.addListener(() => notifications.add(null));

        final points = createLinePoints(count: 5, startY: 0);

        controller.startStroke(points.first, color: Colors.amber, baseWidth: 6);
        for (final point in points.skip(1)) {
          controller.updateStroke(point);
        }

        final accepted = await controller.endStroke();

        expect(accepted, isTrue);
        expect(controller.strokes, hasLength(1));
        expect(controller.currentStroke, isNull);
        expect(controller.canUndo, isTrue);
        expect(controller.canRedo, isFalse);
        expect(controller.strokesVersion, 1);
        expect(
          controller.strokes.first.points.first.position,
          equals(points.first.position),
        );
        expect(
          controller.strokes.first.points.last.position,
          equals(points.last.position),
        );
        expect(notifications.length, greaterThanOrEqualTo(3));
      },
    );

    test('undo and redo manipulate stroke history correctly', () async {
      await drawStroke(
        controller,
        points: createLinePoints(count: 6, startY: 0),
        color: Colors.deepPurple,
      );
      await drawStroke(
        controller,
        points: createLinePoints(count: 6, startY: 40),
        color: Colors.green,
      );

      expect(controller.strokes, hasLength(2));
      expect(controller.strokesVersion, 2);
      expect(controller.canUndo, isTrue);

      final undoResult = controller.undo();
      expect(undoResult, isTrue);
      expect(controller.strokes, hasLength(1));
      expect(controller.canRedo, isTrue);
      expect(controller.strokesVersion, 3);

      final redoResult = controller.redo();
      expect(redoResult, isTrue);
      expect(controller.strokes, hasLength(2));
      expect(controller.canRedo, isFalse);
      expect(controller.strokesVersion, 4);
    });

    test('clear removes all strokes and resets redo history', () async {
      await drawStroke(
        controller,
        points: createLinePoints(count: 5, startY: 10),
        color: Colors.indigo,
      );

      final cleared = controller.clear();

      expect(cleared, isTrue);
      expect(controller.strokes, isEmpty);
      expect(controller.canUndo, isFalse);
      expect(controller.canRedo, isFalse);
      expect(controller.strokesVersion, 2);
    });

    test(
      'cancelCurrentStroke aborts drawing without affecting committed strokes',
      () async {
        controller.startStroke(
          DrawingPoint(position: const Offset(0, 0)),
          color: Colors.orange,
          baseWidth: 5,
        );
        controller.updateStroke(DrawingPoint(position: const Offset(10, 0)));

        controller.cancelCurrentStroke();

        expect(controller.currentStroke, isNull);
        expect(controller.strokes, isEmpty);
        expect(controller.canUndo, isFalse);
      },
    );

    test('stress: handles 150 strokes with 200 points each', () async {
      const strokeCount = 150;
      const pointsPerStroke = 200; // below async simplification threshold

      for (var i = 0; i < strokeCount; i++) {
        final points = createLinePoints(
          count: pointsPerStroke,
          startY: i * 8.0,
          horizontalJitter: i.isEven ? 0.0 : 2.0,
        );
        await drawStroke(
          controller,
          points: points,
          color: i.isEven ? Colors.black : Colors.grey,
        );
      }

      expect(controller.strokes, hasLength(strokeCount));
      expect(controller.strokesVersion, strokeCount);
      expect(
        controller.strokes.every((Stroke stroke) => stroke.points.length >= 2),
        isTrue,
      );

      var undoCounter = 0;
      while (controller.undo()) {
        undoCounter++;
      }
      expect(undoCounter, strokeCount);
      expect(controller.strokes, isEmpty);
      expect(controller.canRedo, isTrue);

      var redoCounter = 0;
      while (controller.redo()) {
        redoCounter++;
      }
      expect(redoCounter, strokeCount);
      expect(controller.strokes, hasLength(strokeCount));
      expect(controller.canRedo, isFalse);
    });
  });
}

List<DrawingPoint> createLinePoints({
  required int count,
  required double startY,
  double startX = 0,
  double horizontalStep = 4,
  double verticalStep = 4,
  double horizontalJitter = 0,
}) {
  assert(count >= 2, 'A stroke needs at least two points');
  final List<DrawingPoint> points = <DrawingPoint>[];
  for (var i = 0; i < count; i++) {
    final jitter = horizontalJitter == 0 ? 0.0 : math.sin(i) * horizontalJitter;
    points.add(
      DrawingPoint(
        position: Offset(
          startX + (i * horizontalStep) + jitter,
          startY + (i * verticalStep),
        ),
        pressure: 0.5 + ((i % 3) * 0.1),
      ),
    );
  }
  return points;
}

Future<void> drawStroke(
  DrawingController controller, {
  required List<DrawingPoint> points,
  required Color color,
  double baseWidth = 5,
}) async {
  controller.startStroke(points.first, color: color, baseWidth: baseWidth);
  for (final point in points.skip(1)) {
    controller.updateStroke(point);
  }
  await controller.endStroke();
}
