import 'dart:math' as math;
import 'package:inkpadu/features/drawing/application/shape_recognizer.dart';
import 'package:inkpadu/features/drawing/domain/drawing_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShapeRecognizer', () {
    test('recognizes a line', () {
      final points = [
        DrawingPoint(position: const Offset(0, 0)),
        DrawingPoint(position: const Offset(10, 10)),
        DrawingPoint(position: const Offset(20, 20)),
        DrawingPoint(position: const Offset(100, 100)),
      ];

      final match = ShapeRecognizer.recognizeShape(points, 5.0);
      expect(match, isNotNull);
      expect(match!.type, equals(ShapeType.line));
      expect(match, isA<LineMatch>());
    });

    test('recognizes a triangle', () {
      // 3 corners + closed
      // Need enough points so RDP doesn't kill it
      final points = <DrawingPoint>[];
      final vertices = [const Offset(0, 0), const Offset(100, 0), const Offset(50, 100)];

      // Interpolate lines
      void addLine(Offset start, Offset end) {
        for(int i=0; i<=10; i++) {
          final t = i / 10.0;
          points.add(DrawingPoint(
            position: Offset.lerp(start, end, t)!,
          ));
        }
      }

      addLine(vertices[0], vertices[1]);
      addLine(vertices[1], vertices[2]);
      addLine(vertices[2], vertices[0]);

      final match = ShapeRecognizer.recognizeShape(points, 2.0);
      expect(match, isNotNull);
      expect(match!.type, equals(ShapeType.triangle));
      expect(match, isA<TriangleMatch>());
    });

    test('recognizes a rectangle', () {
      final points = <DrawingPoint>[];
      final vertices = [const Offset(0, 0), const Offset(100, 0), const Offset(100, 50), const Offset(0, 50)];

      void addLine(Offset start, Offset end) {
        for(int i=0; i<=10; i++) {
          final t = i / 10.0;
          points.add(DrawingPoint(
            position: Offset.lerp(start, end, t)!,
          ));
        }
      }

      addLine(vertices[0], vertices[1]);
      addLine(vertices[1], vertices[2]);
      addLine(vertices[2], vertices[3]);
      addLine(vertices[3], vertices[0]);

      final match = ShapeRecognizer.recognizeShape(points, 2.0);
      expect(match, isNotNull);
      expect(match!.type, equals(ShapeType.rectangle));
      expect(match, isA<RectangleMatch>());
    });

    test('recognizes an ellipse', () {
      final points = <DrawingPoint>[];
      final center = const Offset(100, 100);
      final radius = 50.0;
      const int steps = 40;

      for(int i=0; i<=steps; i++) {
        final t = (i / steps) * 2 * math.pi;
        points.add(DrawingPoint(
           position: Offset(center.dx + radius * math.cos(t), center.dy + radius * math.sin(t)),
        ));
      }

      final match = ShapeRecognizer.recognizeShape(points, 5.0);
      expect(match, isNotNull);
      expect(match!.type, equals(ShapeType.ellipse));
      expect(match, isA<EllipseMatch>());
    });
  });
}
