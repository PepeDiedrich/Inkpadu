import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart';
import 'package:ai_handwriting_app/features/drawing/application/drawing_snapshot_service.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DrawingSnapshotService', () {
    const service = DrawingSnapshotService();

    Stroke createStroke(List<Offset> points) {
      return Stroke(
        points: points
            .map((p) => DrawingPoint(position: p, pressure: 0.5))
            .toList(),
        baseWidth: 2.0,
      );
    }

    RotatedBoundingBox createBoundingBox(List<Offset> corners) {
      // Simplified bounding box creation for testing
      double minX = double.infinity, maxX = double.negativeInfinity;
      double minY = double.infinity, maxY = double.negativeInfinity;
      for (final p in corners) {
        if (p.dx < minX) minX = p.dx;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dy > maxY) maxY = p.dy;
      }
      return RotatedBoundingBox(
        corners: corners,
        angle: 0,
        width: maxX - minX,
        height: maxY - minY,
      );
    }

    test('captureClusters returns empty list for empty input', () async {
      final result = await service.captureClusters([]);
      expect(result, isEmpty);
    });

    test('captureClusters returns snapshot for valid cluster', () async {
      final stroke = createStroke(const [Offset(0, 0), Offset(10, 10)]);
      final boundingBox = createBoundingBox(
        const [Offset(0, 0), Offset(10, 0), Offset(10, 10), Offset(0, 10)],
      );
      final cluster = StrokeBoundingBoxCluster(
        boundingBox: boundingBox,
        strokes: [stroke],
      );

      final result = await service.captureClusters([cluster]);

      expect(result, hasLength(1));
      expect(result.first.cluster, equals(cluster));
      expect(result.first.pngBytes, isNotEmpty);
      // Check if bounding rect is expanded (default padding is 16)
      expect(result.first.boundingRect.left, closeTo(-16.0, 0.1));
      expect(result.first.boundingRect.top, closeTo(-16.0, 0.1));
    });

    test('captureCombinedSnapshot returns null for empty input', () async {
      final result = await service.captureCombinedSnapshot([]);
      expect(result, isNull);
    });

    test('captureCombinedSnapshot returns snapshot for multiple clusters',
        () async {
      final stroke1 = createStroke(const [Offset(0, 0), Offset(10, 10)]);
      final bbox1 = createBoundingBox(
        const [Offset(0, 0), Offset(10, 0), Offset(10, 10), Offset(0, 10)],
      );
      final cluster1 = StrokeBoundingBoxCluster(
        boundingBox: bbox1,
        strokes: [stroke1],
      );

      final stroke2 = createStroke(const [Offset(20, 20), Offset(30, 30)]);
      final bbox2 = createBoundingBox(
        const [Offset(20, 20), Offset(30, 20), Offset(30, 30), Offset(20, 30)],
      );
      final cluster2 = StrokeBoundingBoxCluster(
        boundingBox: bbox2,
        strokes: [stroke2],
      );

      final result = await service.captureCombinedSnapshot([cluster1, cluster2]);

      expect(result, isNotNull);
      expect(result!.pngBytes, isNotEmpty);
      expect(result.logicalSize.width, greaterThan(0));
      expect(result.logicalSize.height, greaterThan(0));
    });
  });
}
