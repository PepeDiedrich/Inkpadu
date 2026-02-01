import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_cluster_utils.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/cluster_shape_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssistantClusterUtils', () {
    // Helper to create a dummy stroke
    Stroke createStroke(String id, List<Offset> points) => Stroke(
      id: id,
      points: points
          .map((p) => DrawingPoint(position: p, pressure: 1.0))
          .toList(),
      baseWidth: 1.0,
    );

    // Helper to create a dummy cluster
    StrokeBoundingBoxCluster createCluster(
      List<Stroke> strokes,
      RotatedBoundingBox box,
    ) =>
        StrokeBoundingBoxCluster(
          boundingBox: box,
          strokes: strokes,
        );

    test('computeClusterSignature returns null for empty clusters', () {
      final result = AssistantClusterUtils.computeClusterSignature([]);
      expect(result, isNull);
    });

    test('computeClusterSignature formats signature correctly for single cluster',
        () {
      final box = RotatedBoundingBox(
        corners: const [
          Offset(0, 0),
          Offset(10, 0),
          Offset(10, 10),
          Offset(0, 10),
        ],
        angle: 0.0,
        width: 10.0,
        height: 10.0,
      );
      final strokes = [createStroke('s1', const [Offset(5, 5)])];
      final cluster = createCluster(strokes, box);

      final result = AssistantClusterUtils.computeClusterSignature([cluster]);

      // format: id|c1;c2;c3;c4|width|height|angle
      // corners: 0.0:0.0;10.0:0.0;10.0:10.0;0.0:10.0
      const expected =
          's1|0.0:0.0;10.0:0.0;10.0:10.0;0.0:10.0|10.0|10.0|0.000';
      expect(result, expected);
    });

    test('computeClusterSignature sorts entries', () {
      final box1 = RotatedBoundingBox(
        corners: const [Offset.zero, Offset.zero, Offset.zero, Offset.zero],
        angle: 0,
        width: 0,
        height: 0,
      );
      final strokes1 = [createStroke('b', const [])];
      final cluster1 = createCluster(strokes1, box1);

      final box2 = RotatedBoundingBox(
        corners: const [Offset.zero, Offset.zero, Offset.zero, Offset.zero],
        angle: 0,
        width: 0,
        height: 0,
      );
      final strokes2 = [createStroke('a', const [])];
      final cluster2 = createCluster(strokes2, box2);

      final result = AssistantClusterUtils.computeClusterSignature([
        cluster1,
        cluster2,
      ]);

      // Should be sorted by the string representation.
      // 'a|...' comes before 'b|...'
      expect(result, startsWith('a|'));
      expect(result, contains('#b|'));
    });

     test('computeClusterSignature sorts stroke IDs within cluster', () {
       final box = RotatedBoundingBox(
        corners: const [Offset.zero, Offset.zero, Offset.zero, Offset.zero],
        angle: 0,
        width: 0,
        height: 0,
      );
      final strokes = [
        createStroke('s2', const []),
        createStroke('s1', const []),
      ];
      final cluster = createCluster(strokes, box);

      final result = AssistantClusterUtils.computeClusterSignature([cluster]);

      expect(result, startsWith('s1,s2|'));
     });

    test('computeClusterShapes returns empty list for empty input', () {
      final result = AssistantClusterUtils.computeClusterShapes([]);
      expect(result, isEmpty);
    });

    test('computeClusterShapes ignores empty clusters', () {
      final box = RotatedBoundingBox(
        corners: const [
          Offset.zero,
          Offset.zero,
          Offset.zero,
          Offset.zero,
        ],
        angle: 0,
        width: 0,
        height: 0,
      );
      final cluster = createCluster([], box);

      final result = AssistantClusterUtils.computeClusterShapes([cluster]);
      expect(result, isEmpty);
    });

    test('computeClusterShapes returns correct shape data', () {
       final box = RotatedBoundingBox(
        corners: const [
          Offset(0, 0),
          Offset(10, 0),
          Offset(10, 10),
          Offset(0, 10),
        ],
        angle: 0.0,
        width: 10.0,
        height: 10.0,
      );
      // Valid stroke points to form a hull
      final strokes = [createStroke('s1', const [Offset(1, 1), Offset(9, 9), Offset(1, 9)])];
      final cluster = createCluster(strokes, box);

      final result = AssistantClusterUtils.computeClusterShapes([cluster]);

      expect(result, hasLength(1));
      expect(result.first.boundingCorners, box.corners);
      // Hull calculation is implementation detail of ConvexHullCalculator,
      // but assuming it works, we should get some points.
      expect(result.first.hull, isNotEmpty);
      expect(result.first, isA<ClusterShapeData>());
    });
  });
}
