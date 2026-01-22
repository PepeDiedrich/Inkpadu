import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart'
    show StrokeBoundingBoxCluster, ConvexHullCalculator;

import 'package:ai_handwriting_app/features/ink/application/assistant/cluster_shape_data.dart';

/// Hilfsmethoden für die Analyse von Stroke-Clustern im Assistenten.
class AssistantClusterUtils {
  const AssistantClusterUtils._();

  /// Erstellt eine deterministische Signatur auf Basis der Clustergeometrie.
  static String? computeClusterSignature(
    List<StrokeBoundingBoxCluster> clusters,
  ) {
    if (clusters.isEmpty) {
      return null;
    }

    final List<String> entries = <String>[];
    for (final StrokeBoundingBoxCluster cluster in clusters) {
      final List<String> strokeIds = List<String>.from(cluster.strokeIds)
        ..sort();
      final List<String> corners = cluster.boundingBox.corners
          .map(
            (Offset corner) =>
                '${corner.dx.toStringAsFixed(1)}:${corner.dy.toStringAsFixed(1)}',
          )
          .toList(growable: false);
      entries.add(
        '${strokeIds.join(',')}|${corners.join(';')}|'
        '${cluster.boundingBox.width.toStringAsFixed(1)}|'
        '${cluster.boundingBox.height.toStringAsFixed(1)}|'
        '${cluster.boundingBox.angle.toStringAsFixed(3)}',
      );
    }

    entries.sort();
    return entries.join('#');
  }

  /// Berechnet die Polygondaten für die Visualisierung der Cluster.
  static List<ClusterShapeData> computeClusterShapes(
    List<StrokeBoundingBoxCluster> clusters,
  ) {
    if (clusters.isEmpty) {
      return const <ClusterShapeData>[];
    }

    final List<ClusterShapeData> shapes = <ClusterShapeData>[];
    for (final StrokeBoundingBoxCluster cluster in clusters) {
      if (!cluster.hasContent) {
        continue;
      }

      final List<Offset> hull = List<Offset>.from(
        ConvexHullCalculator.convexHullForCluster(cluster),
        growable: false,
      );
      final List<Offset> corners = List<Offset>.from(
        cluster.boundingBox.corners,
        growable: false,
      );

      if (hull.isEmpty && corners.isEmpty) {
        continue;
      }

      shapes.add(ClusterShapeData(hull: hull, boundingCorners: corners));
    }

    return shapes;
  }
}
