import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_cluster_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssistantClusterUtils', () {
    Stroke createMockStroke(String id, List<Offset> points) => Stroke(
      id: id,
      points: points.map((p) => DrawingPoint(position: p)).toList(),
    );

    StrokeBoundingBoxCluster createMockCluster(
      List<Stroke> strokes,
      RotatedBoundingBox box,
    ) => StrokeBoundingBoxCluster(boundingBox: box, strokes: strokes);

    group('computeClusterSignature', () {
      test('returns null for empty clusters', () {
        final signature = AssistantClusterUtils.computeClusterSignature([]);
        expect(signature, isNull);
      });

      test('computes correct signature for single cluster', () {
        final stroke = createMockStroke(
          's1',
          [const Offset(0, 0), const Offset(10, 10)],
        );
        final box = RotatedBoundingBox(
          corners: [
            const Offset(0, 0),
            const Offset(10, 0),
            const Offset(10, 10),
            const Offset(0, 10),
          ],
          angle: 0,
          width: 10,
          height: 10,
        );
        final cluster = createMockCluster([stroke], box);

        final signature = AssistantClusterUtils.computeClusterSignature([
          cluster,
        ]);

        // Expected format:
        // strokeIds|corners(x:y)|width|height|angle
        // s1|0.0:0.0;10.0:0.0;10.0:10.0;0.0:10.0|10.0|10.0|0.000
        expect(
          signature,
          's1|0.0:0.0;10.0:0.0;10.0:10.0;0.0:10.0|10.0|10.0|0.000',
        );
      });

      test('sorts stroke IDs within a cluster', () {
        final stroke1 = createMockStroke('b', []);
        final stroke2 = createMockStroke('a', []);
        final box = RotatedBoundingBox(
          corners: List.filled(4, Offset.zero),
          angle: 0,
          width: 0,
          height: 0,
        );
        final cluster = createMockCluster([stroke1, stroke2], box);

        final signature = AssistantClusterUtils.computeClusterSignature([
          cluster,
        ]);

        expect(signature, contains('a,b|'));
      });

      test('sorts multiple clusters in the signature', () {
        final strokeA = createMockStroke('a', []);
        final clusterA = createMockCluster(
          [strokeA],
          RotatedBoundingBox(
            corners: List.filled(4, Offset.zero),
            angle: 0,
            width: 10,
            height: 10,
          ),
        );

        final strokeB = createMockStroke('b', []);
        final clusterB = createMockCluster(
          [strokeB],
          RotatedBoundingBox(
            corners: List.filled(4, Offset.zero),
            angle: 0,
            width: 20, // Different width to distinguish in signature string if needed, but sorting is on the full string
            height: 20,
          ),
        );

        // Signature A starts with "a..."
        // Signature B starts with "b..."
        // Expected order: A # B

        final signature = AssistantClusterUtils.computeClusterSignature([
          clusterB,
          clusterA,
        ]);

        final parts = signature!.split('#');
        expect(parts[0], contains('a|'));
        expect(parts[1], contains('b|'));
      });
    });

    group('computeClusterShapes', () {
      test('returns empty list for empty clusters', () {
        final shapes = AssistantClusterUtils.computeClusterShapes([]);
        expect(shapes, isEmpty);
      });

      test('returns shapes for populated clusters', () {
        // Create a triangle stroke
        final stroke = createMockStroke(
          's1',
          [const Offset(0, 0), const Offset(10, 0), const Offset(5, 10)],
        );
        final box = RotatedBoundingBox(
          corners: [
            const Offset(0, 0),
            const Offset(10, 0),
            const Offset(10, 10),
            const Offset(0, 10),
          ],
          angle: 0,
          width: 10,
          height: 10,
        );
        final cluster = createMockCluster([stroke], box);

        final shapes = AssistantClusterUtils.computeClusterShapes([cluster]);

        expect(shapes, hasLength(1));
        expect(shapes.first.boundingCorners, equals(box.corners));
        // Convex hull should not be empty for a triangle
        expect(shapes.first.hull, isNotEmpty);
      });

      test('skips empty clusters (no strokes)', () {
        final box = RotatedBoundingBox(
          corners: List.filled(4, Offset.zero),
          angle: 0,
          width: 0,
          height: 0,
        );
        final cluster = createMockCluster([], box);

        final shapes = AssistantClusterUtils.computeClusterShapes([cluster]);

        expect(shapes, isEmpty);
      });
    });
  });
}
