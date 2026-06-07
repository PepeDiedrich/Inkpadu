import 'dart:ui';
import 'package:inkpadu/features/drawing/domain/stroke.dart';

/// Utilities for geometry and math computations,
/// such as bounding boxes and lasso selection logic.
class CanvasGeometryUtils {
  /// Selects strokes that fall within a given lasso polygon.
  static ({Set<int> indices, List<Rect> bounds}) selectStrokesWithinLasso(
    List<Stroke> strokes,
    List<Offset> lassoPoints,
  ) {
    final Rect lassoBounds = boundsOfOffsets(lassoPoints);

    final Set<int> selected = <int>{};
    final List<Rect> selectedBounds = <Rect>[];

    for (var i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      if (stroke.points.isEmpty) continue;

      final Rect strokeBounds = boundsOfStroke(stroke);
      if (!lassoBounds.overlaps(strokeBounds)) continue;

      var hit = false;
      for (final point in stroke.points) {
        if (isPointInPolygon(point.position, lassoPoints)) {
          hit = true;
          break;
        }
      }
      if (!hit) continue;

      selected.add(i);
      selectedBounds.add(strokeBounds);
    }

    return (indices: selected, bounds: selectedBounds);
  }

  /// Calculates the bounding box of a list of offsets.
  static Rect boundsOfOffsets(List<Offset> points) {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy > maxY) maxY = p.dy;
    }
    if (!minX.isFinite || !minY.isFinite || !maxX.isFinite || !maxY.isFinite) {
      return Rect.zero;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Calculates the bounding box of a stroke.
  static Rect boundsOfStroke(Stroke stroke) {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    for (final p in stroke.points) {
      final o = p.position;
      if (o.dx < minX) minX = o.dx;
      if (o.dy < minY) minY = o.dy;
      if (o.dx > maxX) maxX = o.dx;
      if (o.dy > maxY) maxY = o.dy;
    }
    if (!minX.isFinite || !minY.isFinite || !maxX.isFinite || !maxY.isFinite) {
      return Rect.zero;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Checks if a point lies within a polygon.
  static bool isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].dx;
      final yi = polygon[i].dy;
      final xj = polygon[j].dx;
      final yj = polygon[j].dy;
      final bool intersect =
          ((yi > point.dy) != (yj > point.dy)) &&
          (point.dx <
              (xj - xi) *
                      (point.dy - yi) /
                      ((yj - yi) == 0 ? 1e-9 : (yj - yi)) +
                  xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }
}
