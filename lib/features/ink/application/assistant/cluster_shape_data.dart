import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Repräsentiert die grafische Form eines Stroke-Clusters.
class ClusterShapeData {
  /// Erstellt Clustergeometrie aus konvexer Hülle und Bounding-Box.
  const ClusterShapeData({
    required this.hull,
    required this.boundingCorners,
  });

  /// Punkte der konvexen Hülle im logischen Koordinatensystem.
  final List<Offset> hull;

  /// Eckpunkte der Bounding-Box im logischen Koordinatensystem.
  final List<Offset> boundingCorners;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! ClusterShapeData) {
      return false;
    }
    return listEquals(hull, other.hull) &&
        listEquals(boundingCorners, other.boundingCorners);
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(hull), Object.hashAll(boundingCorners));
}
