import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_cluster_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssistantClusterUtils', () {
    group('computeClusterSignature', () {
      test('returns null for empty clusters', () {
        final signature = AssistantClusterUtils.computeClusterSignature([]);
        expect(signature, isNull);
      });

      test('computes signature for single cluster', () {
        final cluster = _createCluster(
          id: 's1',
          corners: [
            const Offset(0, 0),
            const Offset(10, 0),
            const Offset(10, 10),
            const Offset(0, 10),
          ],
          width: 10,
          height: 10,
        );

        final signature = AssistantClusterUtils.computeClusterSignature([
          cluster,
        ]);

        const expected =
            's1|0.0:0.0;10.0:0.0;10.0:10.0;0.0:10.0|10.0|10.0|0.000';
        expect(signature, expected);
      });

      test('computes signature for multiple clusters sorted', () {
        final c1 = _createCluster(
          id: 'a',
          corners: [
            const Offset(0, 0),
            const Offset(0, 0),
            const Offset(0, 0),
            const Offset(0, 0),
          ],
        );
        final c2 = _createCluster(
          id: 'b',
          corners: [
            const Offset(1, 1),
            const Offset(1, 1),
            const Offset(1, 1),
            const Offset(1, 1),
          ],
        );

        final signature = AssistantClusterUtils.computeClusterSignature([
          c2,
          c1,
        ]);

        final parts = signature!.split('#');
        expect(parts.length, 2);
        expect(parts[0], startsWith('a|'));
        expect(parts[1], startsWith('b|'));
      });

      test('sorts stroke IDs within a cluster', () {
         final cluster = _createMultiStrokeCluster(
          ids: ['b', 'a'],
          corners: [const Offset(0,0), const Offset(0,0), const Offset(0,0), const Offset(0,0)]
        );

        final signature = AssistantClusterUtils.computeClusterSignature([cluster]);

        expect(signature, startsWith('a,b|'));
      });
    });

    group('computeClusterShapes', () {
      test('returns empty list for empty clusters', () {
        final shapes = AssistantClusterUtils.computeClusterShapes([]);
        expect(shapes, isEmpty);
      });

      test('computes hull and corners for valid cluster', () {
        // Create a cluster with 3 points forming a triangle
        final p1 = const Offset(0, 0);
        final p2 = const Offset(10, 0);
        final p3 = const Offset(0, 10);

        final cluster = _createClusterWithPoints(
          points: [p1, p2, p3],
          corners: [const Offset(0,0), const Offset(10,0), const Offset(0,10), const Offset(0,0)], // Dummy corners
        );

        final shapes = AssistantClusterUtils.computeClusterShapes([cluster]);

        expect(shapes.length, 1);
        final shape = shapes.first;

        // Hull should contain the points
        // The order might vary but for a triangle it should be the 3 points
        expect(shape.hull.length, 3);
        expect(shape.hull, containsAll([p1, p2, p3]));

        expect(shape.boundingCorners.length, 4);
      });

      test('ignores clusters without content', () {
        final clusterNoStrokes = StrokeBoundingBoxCluster(
          boundingBox: RotatedBoundingBox(
            corners: [
              Offset.zero,
              Offset.zero,
              Offset.zero,
              Offset.zero,
            ],
            angle: 0,
            width: 0,
            height: 0,
          ),
          strokes: [],
        );

        final shapes = AssistantClusterUtils.computeClusterShapes([
          clusterNoStrokes,
        ]);
        expect(shapes, isEmpty);
      });
    });
  });
}

StrokeBoundingBoxCluster _createCluster({
  required String id,
  required List<Offset> corners,
  double width = 0,
  double height = 0,
  double angle = 0,
}) =>
    StrokeBoundingBoxCluster(
      boundingBox: RotatedBoundingBox(
        corners: corners,
        angle: angle,
        width: width,
        height: height,
      ),
      strokes: [
        Stroke(
          id: id,
          points: const [],
          baseWidth: 1.0,
        ),
      ],
    );

StrokeBoundingBoxCluster _createMultiStrokeCluster({
  required List<String> ids,
  required List<Offset> corners,
}) =>
    StrokeBoundingBoxCluster(
      boundingBox: RotatedBoundingBox(
        corners: corners,
        angle: 0,
        width: 0,
        height: 0,
      ),
      strokes: ids.map((id) => Stroke(id: id, points: const [])).toList(),
    );

StrokeBoundingBoxCluster _createClusterWithPoints({
  required List<Offset> points,
  required List<Offset> corners,
}) =>
    StrokeBoundingBoxCluster(
      boundingBox: RotatedBoundingBox(
        corners: corners,
        angle: 0,
        width: 0,
        height: 0,
      ),
      strokes: [
        Stroke(
          id: 's1',
          points: points.map((p) => DrawingPoint(position: p)).toList(),
          baseWidth: 1.0,
        ),
      ],
    );
