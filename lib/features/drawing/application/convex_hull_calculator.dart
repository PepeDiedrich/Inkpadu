import 'dart:collection';
import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Container for the result of overlay calculations.
class OverlayResult {
  /// Erstellt ein neues Ergebnis für die Overlay-Berechnung.
  const OverlayResult({required this.hulls, required this.clusters});

  /// Die berechneten Konturen (Hüllen) der Striche.
  final List<List<Offset>> hulls;

  /// Die berechneten Cluster von Strichen mit ihren Bounding-Boxen.
  final List<StrokeBoundingBoxCluster> clusters;
}

/// Berechnet enge Konturen um Strichdaten, indem die Zeichenfläche gerastert
/// und anschließend eine Kontur mittels Marching-Squares extrahiert wird.
class ConvexHullCalculator {
  const ConvexHullCalculator._();

  static const double _boundingBoxComparisonEpsilon = 1e-6;

  /// Calculates hulls and clusters in a background isolate.
  ///
  /// This replaces separate calls to [contoursForStrokes] and [clustersForContours]
  /// to perform all heavy geometry calculations off the UI thread.
  static Future<OverlayResult> calculateOverlays(
    Iterable<Stroke> strokes, {
    double cellSize = _defaultCellSize,
    double padding = _defaultPadding,
    double simplifyToleranceFactor = _rdpToleranceFactor,
    double minimumArea = _minimumPolygonArea,
    double connectionMargin = 32,
  }) async {
    final strokesList = strokes is List<Stroke>
        ? strokes
        : strokes.toList(growable: false);

    final params = _ContoursParams(
      strokes: strokesList,
      cellSize: cellSize,
      padding: padding,
      simplifyToleranceFactor: simplifyToleranceFactor,
      minimumArea: minimumArea,
      connectionMargin: connectionMargin,
    );

    final resultDTO = await compute(_computeOverlaysIsolate, params);

    // Map DTO back to domain objects
    final strokeMap = {for (final s in strokesList) s.id: s};

    final clusters = resultDTO.clusters
        .map((dto) {
          final clusterStrokes = dto.strokeIds
              .map((id) => strokeMap[id])
              .whereType<Stroke>()
              .toList(growable: false);

          return StrokeBoundingBoxCluster(
            boundingBox: dto.boundingBox,
            strokes: clusterStrokes,
          );
        })
        .toList(growable: false);

    return OverlayResult(hulls: resultDTO.hulls, clusters: clusters);
  }

  /// Erstellt Konturen für die gegebenen [strokes] asynchron in einem Isolate.
  static Future<List<List<Offset>>> contoursForStrokes(
    Iterable<Stroke> strokes, {
    double cellSize = _defaultCellSize,
    double padding = _defaultPadding,
    double simplifyToleranceFactor = _rdpToleranceFactor,
    double minimumArea = _minimumPolygonArea,
    double connectionMargin = 32,
  }) async {
    final strokesList = strokes is List<Stroke>
        ? strokes
        : strokes.toList(growable: false);

    final params = _ContoursParams(
      strokes: strokesList,
      cellSize: cellSize,
      padding: padding,
      simplifyToleranceFactor: simplifyToleranceFactor,
      minimumArea: minimumArea,
      connectionMargin: connectionMargin,
    );

    // Serialisiere Offsets als Maps für Isolate-Übertragung (analog zur ursprünglichen Implementierung)
    final serializedContours = await compute(_computeContoursIsolate, params);

    // Deserialisiere Offsets
    return serializedContours
        .map(
          (contour) => contour
              .map((offsetMap) {
                final dx = offsetMap[_offsetDxKey];
                final dy = offsetMap[_offsetDyKey];
                if (dx == null || dy == null) {
                  throw StateError(
                    'Ungültige Offset-Daten vom Isolate erhalten',
                  );
                }
                return Offset(dx, dy);
              })
              .toList(growable: false),
        )
        .toList(growable: false);
  }

  /// Synchrone Version der Konturenberechnung für Tests und spezielle Fälle.
  static List<List<Offset>> contoursForStrokesSync(
    Iterable<Stroke> strokes, {
    double cellSize = _defaultCellSize,
    double padding = _defaultPadding,
    double simplifyToleranceFactor = _rdpToleranceFactor,
    double minimumArea = _minimumPolygonArea,
    double connectionMargin = _defaultConnectionMargin,
  }) {
    final _StrokeBounds bounds = _StrokeBounds.fromStrokes(strokes);
    if (!bounds.hasContent) {
      return const [];
    }

    final double effectivePadding = math.max(
      math.max(padding, bounds.maxStrokeWidth),
      connectionMargin,
    );
    final double originX = bounds.minX - effectivePadding;
    final double originY = bounds.minY - effectivePadding;
    final Offset origin = Offset(originX, originY);

    final double width = bounds.width + effectivePadding * 2;
    final double height = bounds.height + effectivePadding * 2;

    final int cellColumns = math.max(1, (width / cellSize).ceil() + 2);
    final int cellRows = math.max(1, (height / cellSize).ceil() + 2);
    final int nodeColumns = cellColumns + 1;
    final int nodeRows = cellRows + 1;

    final List<List<bool>> nodeGrid = List<List<bool>>.generate(
      nodeRows,
      (_) => List<bool>.filled(nodeColumns, false),
      growable: false,
    );

    final double minStrokeRadius = math.max(
      _minimumStrokeRadius,
      cellSize * _minimumNodeRadiusFactor,
    );

    for (final Stroke stroke in strokes) {
      if (stroke.points.length < 2) {
        continue;
      }
      for (var i = 0; i < stroke.points.length - 1; i++) {
        final segment = _StrokeSegment(
          stroke.points[i].position,
          stroke.points[i + 1].position,
          _segmentRadius(stroke, i, minStrokeRadius),
        );
        _rasterizeSegment(segment, nodeGrid, origin, cellSize);
      }
    }

    if (connectionMargin > 0) {
      final int dilationRadius = math.max(
        1,
        (connectionMargin / cellSize).ceil(),
      );
      _dilateNodes(nodeGrid, dilationRadius);
    }

    _fillHoles(nodeGrid);

    final List<_ContourSegment> segments = _generateSegments(
      nodeGrid,
      origin,
      cellSize,
    );

    if (segments.isEmpty) {
      return const [];
    }

    final List<List<Offset>> polygons =
        _segmentsToPolygons(segments, origin, cellSize)
            .where((polygon) {
              final double area = _polygonArea(polygon);
              return area.abs() >= minimumArea;
            })
            .map((polygon) {
              final double tolerance = cellSize * simplifyToleranceFactor;
              return _simplifyPolygon(polygon, tolerance);
            })
            .where((polygon) => polygon.length >= 3)
            .toList(growable: false);

    return polygons;
  }

  /// Liefert für jede Kontur die kleinstmögliche gedrehte Bounding-Box.
  static List<RotatedBoundingBox> boundingBoxesForContours(
    Iterable<List<Offset>> contours,
    Iterable<Stroke> strokes,
  ) => clustersForContours(
    contours,
    strokes,
  ).map((cluster) => cluster.boundingBox).toList(growable: false);

  /// Aggregiert Striche zu Clustern basierend auf den angegebenen [contours].
  static List<StrokeBoundingBoxCluster> clustersForContours(
    Iterable<List<Offset>> contours,
    Iterable<Stroke> strokes,
  ) {
    // This method runs on main thread and can use Path.
    final Map<String, Stroke> remainingStrokes = <String, Stroke>{
      for (final Stroke stroke in strokes) stroke.id: stroke,
    };

    final List<StrokeBoundingBoxCluster> clusters =
        <StrokeBoundingBoxCluster>[];

    for (final List<Offset> contour in contours) {
      if (contour.isEmpty) {
        continue;
      }

      final Path hullPath = Path()..addPolygon(contour, true);
      final Rect hullBounds = hullPath.getBounds();

      final List<Offset> clusterPoints = <Offset>[];
      final List<Stroke> clusterStrokes = <Stroke>[];
      double maxRadius = 0;
      final List<String> assignedIds = <String>[];

      remainingStrokes.forEach((String id, Stroke stroke) {
        if (stroke.points.isEmpty) {
          return;
        }

        if (!_strokeHitsPath(stroke, hullPath, hullBounds)) {
          return;
        }

        clusterPoints.addAll(stroke.points.map((point) => point.position));
        clusterStrokes.add(stroke);
        maxRadius = math.max(maxRadius, _maxStrokeRadius(stroke));
        assignedIds.add(id);
      });

      for (final String id in assignedIds) {
        remainingStrokes.remove(id);
      }

      RotatedBoundingBox? box;
      if (clusterPoints.isNotEmpty) {
        box = minimalBoundingBoxForPolygon(clusterPoints);
        if (box != null && maxRadius > 0) {
          box = box.expand(maxRadius);
        }
      } else {
        box = minimalBoundingBoxForPolygon(contour);
      }

      if (box != null) {
        clusters.add(
          StrokeBoundingBoxCluster(boundingBox: box, strokes: clusterStrokes),
        );
      }
    }

    if (remainingStrokes.isNotEmpty) {
      for (final Stroke stroke in remainingStrokes.values) {
        if (stroke.points.isEmpty) {
          continue;
        }
        final List<Offset> points = stroke.points
            .map((point) => point.position)
            .toList(growable: false);
        RotatedBoundingBox? box = minimalBoundingBoxForPolygon(points);
        if (box != null) {
          final double maxRadius = _maxStrokeRadius(stroke);
          if (maxRadius > 0) {
            box = box.expand(maxRadius);
          }
          clusters.add(
            StrokeBoundingBoxCluster(
              boundingBox: box,
              strokes: <Stroke>[stroke],
            ),
          );
        }
      }
    }

    // Versuche, überlappende Cluster zu verschmelzen
    bool merged = true;
    while (merged) {
      merged = false;
      for (var i = 0; i < clusters.length; i++) {
        for (var j = i + 1; j < clusters.length; j++) {
          final boxA = clusters[i].boundingBox;
          final boxB = clusters[j].boundingBox;

          if (boxA.overlaps(boxB)) {
            final combinedStrokes = <Stroke>[
              ...clusters[i].strokes,
              ...clusters[j].strokes,
            ];

            final allPoints = <Offset>[];
            for (final stroke in combinedStrokes) {
              allPoints.addAll(stroke.points.map((p) => p.position));
            }

            RotatedBoundingBox? newBox = minimalBoundingBoxForPolygon(
              allPoints,
            );
            if (newBox != null) {
              double maxRadius = 0;
              for (final s in combinedStrokes) {
                maxRadius = math.max(maxRadius, _maxStrokeRadius(s));
              }
              if (maxRadius > 0) {
                newBox = newBox.expand(maxRadius);
              }

              clusters[i] = StrokeBoundingBoxCluster(
                boundingBox: newBox,
                strokes: combinedStrokes,
              );
              clusters.removeAt(j);

              merged = true;
              break;
            }
          }
        }
        if (merged) break;
      }
    }

    return clusters;
  }

  /// Berechnet die konvexe Hülle aller Punkte innerhalb des [cluster].
  static List<Offset> convexHullForCluster(StrokeBoundingBoxCluster cluster) {
    final List<Offset> points = cluster.strokes
        .expand((stroke) => stroke.points.map((point) => point.position))
        .toList(growable: false);
    if (points.isEmpty) {
      return const <Offset>[];
    }
    return _computeConvexHull(points);
  }

  /// Berechnet die minimale Bounding-Box für ein einzelnes Polygon.
  static RotatedBoundingBox? minimalBoundingBoxForPolygon(
    List<Offset> polygon,
  ) {
    if (polygon.isEmpty) {
      return null;
    }

    final List<Offset> hull = _computeConvexHull(polygon);
    if (hull.isEmpty) {
      return null;
    }

    if (hull.length == 1) {
      return RotatedBoundingBox.singlePoint(hull.first);
    }
    if (hull.length == 2) {
      return RotatedBoundingBox.fromSegment(hull[0], hull[1]);
    }

    double bestArea = double.infinity;
    double bestAngle = 0;
    double bestCos = 1;
    double bestSin = 0;
    double bestMinX = 0;
    double bestMaxX = 0;
    double bestMinY = 0;
    double bestMaxY = 0;

    for (var i = 0; i < hull.length; i++) {
      final Offset current = hull[i];
      final Offset next = hull[(i + 1) % hull.length];
      final Offset edge = next - current;
      if (edge == Offset.zero) {
        continue;
      }

      final double angle = math.atan2(edge.dy, edge.dx);
      final double cosAngle = math.cos(angle);
      final double sinAngle = math.sin(angle);

      double minX = double.infinity;
      double maxX = -double.infinity;
      double minY = double.infinity;
      double maxY = -double.infinity;

      for (final Offset point in hull) {
        final double rotatedX = point.dx * cosAngle + point.dy * sinAngle;
        final double rotatedY = -point.dx * sinAngle + point.dy * cosAngle;
        if (rotatedX < minX) minX = rotatedX;
        if (rotatedX > maxX) maxX = rotatedX;
        if (rotatedY < minY) minY = rotatedY;
        if (rotatedY > maxY) maxY = rotatedY;
      }

      final double width = maxX - minX;
      final double height = maxY - minY;
      final double area = width * height;

      if (area < bestArea - _boundingBoxComparisonEpsilon) {
        bestArea = area;
        bestAngle = angle;
        bestCos = cosAngle;
        bestSin = sinAngle;
        bestMinX = minX;
        bestMaxX = maxX;
        bestMinY = minY;
        bestMaxY = maxY;
      }
    }

    if (!bestArea.isFinite) {
      return null;
    }

    final double width = bestMaxX - bestMinX;
    final double height = bestMaxY - bestMinY;

    final List<Offset> rotatedCorners = <Offset>[
      Offset(bestMinX, bestMinY),
      Offset(bestMaxX, bestMinY),
      Offset(bestMaxX, bestMaxY),
      Offset(bestMinX, bestMaxY),
    ];

    final List<Offset> corners = rotatedCorners
        .map(
          (Offset corner) => Offset(
            corner.dx * bestCos - corner.dy * bestSin,
            corner.dx * bestSin + corner.dy * bestCos,
          ),
        )
        .toList(growable: false);

    return RotatedBoundingBox(
      corners: corners,
      angle: bestAngle,
      width: width,
      height: height,
    );
  }

  static List<Offset> _computeConvexHull(List<Offset> points) {
    if (points.isEmpty) {
      return const <Offset>[];
    }

    if (points.length == 1) {
      return <Offset>[points.first];
    }

    final List<Offset> sorted = points.toSet().toList(growable: false)
      ..sort((Offset a, Offset b) {
        final int compareX = a.dx.compareTo(b.dx);
        if (compareX != 0) {
          return compareX;
        }
        return a.dy.compareTo(b.dy);
      });

    if (sorted.length <= 2) {
      return sorted;
    }

    final List<Offset> lower = <Offset>[];
    for (final Offset point in sorted) {
      while (lower.length >= 2 &&
          _cross(lower[lower.length - 2], lower.last, point) <= 0) {
        lower.removeLast();
      }
      lower.add(point);
    }

    final List<Offset> upper = <Offset>[];
    for (final Offset point in sorted.reversed) {
      while (upper.length >= 2 &&
          _cross(upper[upper.length - 2], upper.last, point) <= 0) {
        upper.removeLast();
      }
      upper.add(point);
    }

    lower.removeLast();
    upper.removeLast();
    lower.addAll(upper);
    return lower;
  }

  static double _cross(Offset origin, Offset a, Offset b) =>
      (a.dx - origin.dx) * (b.dy - origin.dy) -
      (a.dy - origin.dy) * (b.dx - origin.dx);

  static bool _strokeHitsPath(Stroke stroke, Path path, Rect bounds) {
    for (final point in stroke.points) {
      final Offset position = point.position;
      if (!bounds.contains(position)) {
        continue;
      }
      if (path.contains(position)) {
        return true;
      }
    }
    return false;
  }

  static bool _strokeHitsPolygon(
    Stroke stroke,
    List<Offset> polygon,
    Rect bounds,
  ) {
    for (final point in stroke.points) {
      final Offset position = point.position;
      if (!bounds.contains(position)) {
        continue;
      }
      if (_isPointInPolygon(position, polygon)) {
        return true;
      }
    }
    return false;
  }

  static bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    bool isInside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if (((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy)) &&
          (point.dx <
              (polygon[j].dx - polygon[i].dx) *
                      (point.dy - polygon[i].dy) /
                      (polygon[j].dy - polygon[i].dy) +
                  polygon[i].dx)) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  static Rect _computeBounds(List<Offset> points) {
    if (points.isEmpty) return Rect.zero;
    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  static double _maxStrokeRadius(Stroke stroke) {
    double maxRadius = 0;
    for (final point in stroke.points) {
      final double pressure = point.pressure;
      final double radius = stroke.baseWidth * pressure * 0.5;
      if (radius > maxRadius) {
        maxRadius = radius;
      }
    }
    if (maxRadius == 0) {
      return stroke.baseWidth * 0.5;
    }
    return maxRadius;
  }

  static double _segmentRadius(Stroke stroke, int index, double minRadius) {
    final pointA = stroke.points[index];
    final pointB = stroke.points[index + 1];
    final double pressure = (pointA.pressure + pointB.pressure) * 0.5;
    final double width = stroke.baseWidth * pressure;
    return math.max(width * 0.5, minRadius);
  }

  static void _rasterizeSegment(
    _StrokeSegment segment,
    List<List<bool>> grid,
    Offset origin,
    double cellSize,
  ) {
    final double length = (segment.end - segment.start).distance;
    final double step = math.max(cellSize * 0.5, _minimumSamplingStep);
    final int iterations = math.max(1, (length / step).ceil());

    for (var i = 0; i <= iterations; i++) {
      final double t = i / iterations;
      final Offset position = Offset(
        _lerp(segment.start.dx, segment.end.dx, t),
        _lerp(segment.start.dy, segment.end.dy, t),
      );
      _stampCircle(grid, origin, cellSize, position, segment.radius);
    }
  }

  static void _stampCircle(
    List<List<bool>> grid,
    Offset origin,
    double cellSize,
    Offset center,
    double radius,
  ) {
    final int maxColumn = grid[0].length - 1;
    final int maxRow = grid.length - 1;

    final double gridCenterX = (center.dx - origin.dx) / cellSize;
    final double gridCenterY = (center.dy - origin.dy) / cellSize;
    final double gridRadius = radius / cellSize;

    final int minX = math.max(0, (gridCenterX - gridRadius).floor());
    final int maxX = math.min(maxColumn, (gridCenterX + gridRadius).ceil());
    final int minY = math.max(0, (gridCenterY - gridRadius).floor());
    final int maxY = math.min(maxRow, (gridCenterY + gridRadius).ceil());

    final double radiusSquared = radius * radius;

    for (var y = minY; y <= maxY; y++) {
      final double nodeY = origin.dy + y * cellSize;
      for (var x = minX; x <= maxX; x++) {
        final double nodeX = origin.dx + x * cellSize;
        final double dx = nodeX - center.dx;
        final double dy = nodeY - center.dy;
        if ((dx * dx + dy * dy) <= radiusSquared) {
          grid[y][x] = true;
        }
      }
    }
  }

  static void _dilateNodes(List<List<bool>> grid, int radiusCells) {
    if (radiusCells <= 0) {
      return;
    }

    final int rows = grid.length;
    final int columns = grid[0].length;
    final List<List<bool>> snapshot = List<List<bool>>.generate(
      rows,
      (int y) => List<bool>.from(grid[y], growable: false),
      growable: false,
    );
    final int radiusSquared = radiusCells * radiusCells;

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        if (!snapshot[y][x]) {
          continue;
        }
        final int minY = math.max(0, y - radiusCells);
        final int maxY = math.min(rows - 1, y + radiusCells);
        final int minX = math.max(0, x - radiusCells);
        final int maxX = math.min(columns - 1, x + radiusCells);
        for (var ny = minY; ny <= maxY; ny++) {
          final int dy = ny - y;
          for (var nx = minX; nx <= maxX; nx++) {
            final int dx = nx - x;
            if ((dx * dx + dy * dy) <= radiusSquared) {
              grid[ny][nx] = true;
            }
          }
        }
      }
    }
  }

  static void _fillHoles(List<List<bool>> grid) {
    final int rows = grid.length;
    final int columns = grid[0].length;
    final List<List<bool>> visited = List<List<bool>>.generate(
      rows,
      (_) => List<bool>.filled(columns, false),
      growable: false,
    );
    final Queue<_GridPoint> queue = Queue<_GridPoint>();

    void enqueue(int x, int y) {
      if (visited[y][x] || grid[y][x]) {
        return;
      }
      visited[y][x] = true;
      queue.add(_GridPoint(x, y));
    }

    for (var x = 0; x < columns; x++) {
      enqueue(x, 0);
      enqueue(x, rows - 1);
    }
    for (var y = 1; y < rows - 1; y++) {
      enqueue(0, y);
      enqueue(columns - 1, y);
    }

    while (queue.isNotEmpty) {
      final _GridPoint point = queue.removeFirst();
      for (final _GridPoint offset in _neighborOffsets) {
        final int nx = point.x + offset.x;
        final int ny = point.y + offset.y;
        if (nx < 0 || nx >= columns || ny < 0 || ny >= rows) {
          continue;
        }
        if (visited[ny][nx] || grid[ny][nx]) {
          continue;
        }
        visited[ny][nx] = true;
        queue.add(_GridPoint(nx, ny));
      }
    }

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        if (!grid[y][x] && !visited[y][x]) {
          grid[y][x] = true;
        }
      }
    }
  }

  static List<_ContourSegment> _generateSegments(
    List<List<bool>> grid,
    Offset origin,
    double cellSize,
  ) {
    final List<_ContourSegment> segments = <_ContourSegment>[];
    final int rows = grid.length - 1;
    final int columns = grid[0].length - 1;

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        final bool topLeft = grid[y][x];
        final bool topRight = grid[y][x + 1];
        final bool bottomRight = grid[y + 1][x + 1];
        final bool bottomLeft = grid[y + 1][x];

        final int mask = _cellMask(topLeft, topRight, bottomRight, bottomLeft);
        if (mask == 0 || mask == 15) {
          continue;
        }

        final List<_EdgePair> pairs = _edgePairsForMask(
          mask,
          topLeft,
          topRight,
          bottomRight,
          bottomLeft,
        );

        for (final _EdgePair pair in pairs) {
          final _ContourPoint start = _edgePoint(x, y, pair.start);
          final _ContourPoint end = _edgePoint(x, y, pair.end);
          segments.add(_ContourSegment(start, end));
        }
      }
    }

    return segments;
  }

  static List<List<Offset>> _segmentsToPolygons(
    List<_ContourSegment> segments,
    Offset origin,
    double cellSize,
  ) {
    final Map<_ContourPoint, Set<_ContourPoint>> adjacency =
        <_ContourPoint, Set<_ContourPoint>>{};

    void addEdge(_ContourPoint a, _ContourPoint b) {
      adjacency.putIfAbsent(a, () => <_ContourPoint>{}).add(b);
      adjacency.putIfAbsent(b, () => <_ContourPoint>{}).add(a);
    }

    for (final _ContourSegment segment in segments) {
      addEdge(segment.start, segment.end);
    }

    final List<List<Offset>> polygons = <List<Offset>>[];

    while (adjacency.isNotEmpty) {
      final _ContourPoint start = adjacency.keys.first;
      final List<_ContourPoint> contour = <_ContourPoint>[];

      _ContourPoint current = start;
      _ContourPoint? previous;

      while (true) {
        contour.add(current);
        final Set<_ContourPoint>? neighbors = adjacency[current];
        if (neighbors == null || neighbors.isEmpty) {
          adjacency.remove(current);
          break;
        }

        _ContourPoint next;
        if (previous == null) {
          next = neighbors.first;
        } else {
          next = neighbors.firstWhere(
            (candidate) => candidate != previous,
            orElse: () => neighbors.first,
          );
        }

        neighbors.remove(next);
        if (neighbors.isEmpty) {
          adjacency.remove(current);
        }

        final Set<_ContourPoint>? reverse = adjacency[next];
        reverse?.remove(current);
        if (reverse != null && reverse.isEmpty) {
          adjacency.remove(next);
        }

        previous = current;
        current = next;

        if (current == start) {
          contour.add(current);
          break;
        }
      }

      final List<_ContourPoint> uniqueContour = _deduplicateContour(contour);
      if (uniqueContour.length < 3) {
        continue;
      }

      final List<Offset> polygon = uniqueContour
          .map(
            (point) => Offset(
              origin.dx + (point.x2 * 0.5 * cellSize),
              origin.dy + (point.y2 * 0.5 * cellSize),
            ),
          )
          .toList(growable: false);
      polygons.add(polygon);
    }

    return polygons;
  }

  static List<_ContourPoint> _deduplicateContour(List<_ContourPoint> contour) {
    if (contour.isEmpty) {
      return contour;
    }
    final List<_ContourPoint> result = <_ContourPoint>[];
    _ContourPoint? previous;
    for (final _ContourPoint point in contour) {
      if (point == previous) {
        continue;
      }
      result.add(point);
      previous = point;
    }
    if (result.length > 1 && result.first == result.last) {
      result.removeLast();
    }
    return result;
  }

  static int _cellMask(
    bool topLeft,
    bool topRight,
    bool bottomRight,
    bool bottomLeft,
  ) {
    var mask = 0;
    if (topLeft) mask |= 8;
    if (topRight) mask |= 4;
    if (bottomRight) mask |= 2;
    if (bottomLeft) mask |= 1;
    return mask;
  }

  static List<_EdgePair> _edgePairsForMask(
    int mask,
    bool topLeft,
    bool topRight,
    bool bottomRight,
    bool bottomLeft,
  ) {
    final List<int> edges = <int>[];

    if (topLeft != topRight) edges.add(0);
    if (topRight != bottomRight) edges.add(1);
    if (bottomRight != bottomLeft) edges.add(2);
    if (bottomLeft != topLeft) edges.add(3);

    if (edges.isEmpty) {
      return const <_EdgePair>[];
    }

    if (edges.length == 2) {
      return <_EdgePair>[_EdgePair(edges[0], edges[1])];
    }

    if (edges.length == 4) {
      if (mask == 5) {
        // Innenpunkte auf der Diagonalen oben links <-> unten rechts.
        return <_EdgePair>[const _EdgePair(0, 3), const _EdgePair(1, 2)];
      }
      if (mask == 10) {
        // Innenpunkte auf der Diagonalen oben rechts <-> unten links.
        return <_EdgePair>[const _EdgePair(0, 1), const _EdgePair(2, 3)];
      }

      return <_EdgePair>[
        _EdgePair(edges[0], edges[1]),
        _EdgePair(edges[2], edges[3]),
      ];
    }

    // Fallback: verbinde aufeinanderfolgende Kanten.
    final List<_EdgePair> pairs = <_EdgePair>[];
    for (var i = 0; i < edges.length; i += 2) {
      final int start = edges[i];
      final int end = edges[(i + 1) % edges.length];
      pairs.add(_EdgePair(start, end));
    }
    return pairs;
  }

  static _ContourPoint _edgePoint(int cellX, int cellY, int edge) {
    switch (edge) {
      case 0:
        return _ContourPoint(2 * cellX + 1, 2 * cellY);
      case 1:
        return _ContourPoint(2 * (cellX + 1), 2 * cellY + 1);
      case 2:
        return _ContourPoint(2 * cellX + 1, 2 * (cellY + 1));
      case 3:
        return _ContourPoint(2 * cellX, 2 * cellY + 1);
      default:
        throw ArgumentError('Unbekannte Kante $edge');
    }
  }

  static List<Offset> _simplifyPolygon(List<Offset> polygon, double tolerance) {
    if (polygon.length <= 3 || tolerance <= 0) {
      return polygon;
    }

    final List<Offset> closed = <Offset>[...polygon];
    if (closed.first != closed.last) {
      closed.add(closed.first);
    }

    final List<bool> keep = List<bool>.filled(closed.length, false);
    keep[0] = true;
    keep[closed.length - 1] = true;

    _rdp(closed, 0, closed.length - 1, tolerance, keep);

    final List<Offset> simplified = <Offset>[];
    for (var i = 0; i < closed.length - 1; i++) {
      if (keep[i]) {
        simplified.add(closed[i]);
      }
    }

    if (simplified.length > 2 && simplified.first == simplified.last) {
      simplified.removeLast();
    }

    return simplified;
  }

  static void _rdp(
    List<Offset> points,
    int start,
    int end,
    double tolerance,
    List<bool> keep,
  ) {
    double maxDistance = 0;
    int index = -1;
    final Offset startPoint = points[start];
    final Offset endPoint = points[end];

    for (var i = start + 1; i < end; i++) {
      final double distance = _perpendicularDistance(
        points[i],
        startPoint,
        endPoint,
      );
      if (distance > maxDistance) {
        index = i;
        maxDistance = distance;
      }
    }

    if (index != -1 && maxDistance > tolerance) {
      keep[index] = true;
      _rdp(points, start, index, tolerance, keep);
      _rdp(points, index, end, tolerance, keep);
    }
  }

  static double _perpendicularDistance(Offset point, Offset start, Offset end) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    if (dx == 0 && dy == 0) {
      return (point - start).distance;
    }
    final double numerator =
        ((point.dx - start.dx) * dy - (point.dy - start.dy) * dx).abs();
    final double denominator = math.sqrt(dx * dx + dy * dy);
    return numerator / denominator;
  }

  static double _polygonArea(List<Offset> polygon) {
    if (polygon.length < 3) {
      return 0;
    }
    double area = 0;
    for (var i = 0; i < polygon.length; i++) {
      final Offset a = polygon[i];
      final Offset b = polygon[(i + 1) % polygon.length];
      area += a.dx * b.dy - b.dx * a.dy;
    }
    return area * 0.5;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Darstellung einer gedrehten Bounding-Box.
class RotatedBoundingBox {
  /// Erstellt eine Bounding-Box aus expliziten Eckpunkten und Abmessungen.
  RotatedBoundingBox({
    required List<Offset> corners,
    required this.angle,
    required this.width,
    required this.height,
  }) : assert(corners.length == 4),
       corners = List<Offset>.unmodifiable(corners),
       area = width * height;

  /// Erzeugt eine Bounding-Box für einen einzelnen Punkt.
  RotatedBoundingBox.singlePoint(Offset point)
    : corners = List<Offset>.unmodifiable(List<Offset>.filled(4, point)),
      angle = 0,
      width = 0,
      height = 0,
      area = 0;

  /// Erzeugt eine Bounding-Box, die genau ein Liniensegment umfasst.
  RotatedBoundingBox.fromSegment(Offset start, Offset end)
    : corners = List<Offset>.unmodifiable(<Offset>[start, end, end, start]),
      angle = math.atan2(end.dy - start.dy, end.dx - start.dx),
      width = (end - start).distance,
      height = 0,
      area = 0;

  /// Eckpunkte im Uhrzeigersinn.
  final List<Offset> corners;

  /// Rotationswinkel relativ zur x-Achse (Radiant).
  final double angle;

  /// Breite der Bounding-Box in Richtung der Basis.
  final double width;

  /// Höhe der Bounding-Box senkrecht zur Basis.
  final double height;

  /// Fläche der Bounding-Box.
  final double area;

  /// Mittelpunkt der Bounding-Box.
  Offset get center => (corners[0] + corners[2]) / 2;

  /// Gibt eine vergrößerte Kopie der Bounding-Box zurück.
  RotatedBoundingBox expand(double margin) {
    if (margin <= 0) {
      return this;
    }

    final double newWidth = width + margin * 2;
    final double newHeight = height + margin * 2;
    if (newWidth <= 0 || newHeight <= 0) {
      return this;
    }

    final Offset centerPoint = center;
    final double cosAngle = math.cos(angle);
    final double sinAngle = math.sin(angle);

    final Offset halfWidthVector = Offset(
      cosAngle * newWidth * 0.5,
      sinAngle * newWidth * 0.5,
    );
    final Offset halfHeightVector = Offset(
      -sinAngle * newHeight * 0.5,
      cosAngle * newHeight * 0.5,
    );

    final List<Offset> newCorners = <Offset>[
      centerPoint - halfWidthVector - halfHeightVector,
      centerPoint + halfWidthVector - halfHeightVector,
      centerPoint + halfWidthVector + halfHeightVector,
      centerPoint - halfWidthVector + halfHeightVector,
    ];

    return RotatedBoundingBox(
      corners: newCorners,
      angle: angle,
      width: newWidth,
      height: newHeight,
    );
  }

  /// Prüft mittels SAT (Separating Axis Theorem), ob sich diese und [other] überschneiden.
  bool overlaps(RotatedBoundingBox other) {
    // Wenn eine der Boxen keine Fläche hat (Linie oder Punkt),
    // machen wir einen einfachen Check oder betrachten es als nicht überlappend für diesen Zweck.
    // Für korrekte "Square merging" wäre es gut, echte Überlappung zu prüfen.
    if (area <= 0 || other.area <= 0) {
      // Fallback: Prüfen ob ein Eckpunkt im anderen Polygon liegt oder umgekehrt.
      // Einfacher SAT funktioniert auch für Liniensegmente, aber wir nutzen hier den vollen SAT für Polygone.
    }

    // Normalen (Achsen) beider Rechtecke sammeln
    final axes = [..._getAxes(), ...other._getAxes()];

    for (final axis in axes) {
      final p1 = _project(axis);
      final p2 = other._project(axis);

      if (!p1.overlaps(p2)) {
        return false;
      }
    }

    return true;
  }

  List<Offset> _getAxes() {
    final axes = <Offset>[];
    // Nur zwei Achsen nötig für Rechteck (Kanten 0-1 und 1-2)
    // 0-1
    final edge1 = corners[1] - corners[0];
    axes.add(Offset(-edge1.dy, edge1.dx)); // Normale
    // 1-2
    final edge2 = corners[2] - corners[1];
    axes.add(Offset(-edge2.dy, edge2.dx)); // Normale
    return axes;
  }

  _Projection _project(Offset axis) {
    double min = double.infinity;
    double max = -double.infinity;

    for (final p in corners) {
      final val = p.dx * axis.dx + p.dy * axis.dy;
      if (val < min) min = val;
      if (val > max) max = val;
    }
    return _Projection(min, max);
  }
}

class _Projection {
  const _Projection(this.min, this.max);
  final double min;
  final double max;

  bool overlaps(_Projection other) => !(max < other.min || other.max < min);
}

/// Gruppiert Striche mit einer zugehörigen Bounding-Box.
class StrokeBoundingBoxCluster {
  /// Erstellt einen neuen Cluster aus [strokes] und der berechneten [boundingBox].
  StrokeBoundingBoxCluster({
    required this.boundingBox,
    required List<Stroke> strokes,
  }) : strokes = List<Stroke>.unmodifiable(strokes),
       strokeIds = List<String>.unmodifiable(
         strokes.map((stroke) => stroke.id),
       );

  /// Begrenzende Box des Clusters.
  final RotatedBoundingBox boundingBox;

  /// Alle Striche, die zu diesem Cluster gehören.
  final List<Stroke> strokes;

  /// Nur die IDs der enthaltenen Striche (zur Effizienz bei Vergleichen).
  final List<String> strokeIds;

  /// Ob der Cluster Zeichendaten enthält.
  bool get hasContent => strokes.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! StrokeBoundingBoxCluster) {
      return false;
    }
    return listEquals(strokeIds, other.strokeIds) &&
        listEquals(boundingBox.corners, other.boundingBox.corners);
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(strokeIds),
    Object.hashAll(boundingBox.corners),
  );
}

class _StrokeSegment {
  const _StrokeSegment(this.start, this.end, this.radius);

  final Offset start;
  final Offset end;
  final double radius;
}

class _EdgePair {
  const _EdgePair(this.start, this.end);

  final int start;
  final int end;
}

class _ContourSegment {
  const _ContourSegment(this.start, this.end);

  final _ContourPoint start;
  final _ContourPoint end;
}

class _ContourPoint {
  const _ContourPoint(this.x2, this.y2);

  final int x2;
  final int y2;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ContourPoint && other.x2 == x2 && other.y2 == y2;
  }

  @override
  int get hashCode => Object.hash(x2, y2);
}

class _StrokeBounds {
  const _StrokeBounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.maxStrokeWidth,
    required this.hasContent,
  });

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;
  final double maxStrokeWidth;
  final bool hasContent;

  double get width => maxX - minX;
  double get height => maxY - minY;

  factory _StrokeBounds.fromStrokes(Iterable<Stroke> strokes) {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    var maxStrokeWidth = 0.0;
    var hasContent = false;

    for (final Stroke stroke in strokes) {
      if (stroke.points.isEmpty) {
        continue;
      }
      hasContent = true;
      if (stroke.baseWidth > maxStrokeWidth) {
        maxStrokeWidth = stroke.baseWidth;
      }
      for (final point in stroke.points) {
        final double dx = point.position.dx;
        final double dy = point.position.dy;
        if (dx < minX) minX = dx;
        if (dy < minY) minY = dy;
        if (dx > maxX) maxX = dx;
        if (dy > maxY) maxY = dy;
      }
    }

    if (!hasContent) {
      return const _StrokeBounds(
        minX: 0,
        minY: 0,
        maxX: 0,
        maxY: 0,
        maxStrokeWidth: 0,
        hasContent: false,
      );
    }

    return _StrokeBounds(
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
      maxStrokeWidth: maxStrokeWidth,
      hasContent: true,
    );
  }
}

const double _defaultCellSize = 4;
const double _defaultPadding = 24;
const double _minimumStrokeRadius = 0.75;
const double _minimumSamplingStep = 1.0;
const double _rdpToleranceFactor = 0.3;
const double _minimumPolygonArea = 32;
const double _defaultConnectionMargin = 32;
const double _minimumNodeRadiusFactor = 0.6;

// Konstanten für Offset-Serialisierung
const String _offsetDxKey = 'dx';
const String _offsetDyKey = 'dy';

class _GridPoint {
  const _GridPoint(this.x, this.y);

  final int x;
  final int y;
}

const List<_GridPoint> _neighborOffsets = <_GridPoint>[
  _GridPoint(1, 0),
  _GridPoint(-1, 0),
  _GridPoint(0, 1),
  _GridPoint(0, -1),
];

/// Parameter-Objekt für die Isolate-Kommunikation.
class _ContoursParams {
  const _ContoursParams({
    required this.strokes,
    required this.cellSize,
    required this.padding,
    required this.simplifyToleranceFactor,
    required this.minimumArea,
    required this.connectionMargin,
  });

  final List<Stroke> strokes;
  final double cellSize;
  final double padding;
  final double simplifyToleranceFactor;
  final double minimumArea;
  final double connectionMargin;
}

class _ClusterDataDTO {
  final RotatedBoundingBox boundingBox;
  final List<String> strokeIds;
  _ClusterDataDTO({required this.boundingBox, required this.strokeIds});
}

class _OverlayResultDTO {
  final List<List<Offset>> hulls;
  final List<_ClusterDataDTO> clusters;
  _OverlayResultDTO({required this.hulls, required this.clusters});
}

/// Top-level Funktion für Isolate-Berechnung (Contours only).
List<List<Map<String, double>>> _computeContoursIsolate(
  _ContoursParams params,
) {
  final contours = ConvexHullCalculator.contoursForStrokesSync(
    params.strokes,
    cellSize: params.cellSize,
    padding: params.padding,
    simplifyToleranceFactor: params.simplifyToleranceFactor,
    minimumArea: params.minimumArea,
    connectionMargin: params.connectionMargin,
  );

  return contours
      .map(
        (contour) => contour
            .map((offset) => {_offsetDxKey: offset.dx, _offsetDyKey: offset.dy})
            .toList(growable: false),
      )
      .toList(growable: false);
}

/// Top-level Funktion für Isolate-Berechnung (Overlays: Contours + Clusters).
_OverlayResultDTO _computeOverlaysIsolate(_ContoursParams params) {
  // 1. Calculate contours (sync)
  final contours = ConvexHullCalculator.contoursForStrokesSync(
    params.strokes,
    cellSize: params.cellSize,
    padding: params.padding,
    simplifyToleranceFactor: params.simplifyToleranceFactor,
    minimumArea: params.minimumArea,
    connectionMargin: params.connectionMargin,
  );

  // 2. Calculate clusters (sync, adapted for isolate)
  // Replaced usage of Path with _isPointInPolygon manual check.

  final clustersDTO = <_ClusterDataDTO>[];
  final Map<String, Stroke> remainingStrokes = {
    for (final Stroke stroke in params.strokes) stroke.id: stroke,
  };

  // Optimization: Map of id -> Stroke for fast lookup during merge
  final Map<String, Stroke> allStrokesMap = {
    for (final Stroke stroke in params.strokes) stroke.id: stroke,
  };

  for (final contour in contours) {
    if (contour.isEmpty) continue;

    final rect = ConvexHullCalculator._computeBounds(contour);

    final clusterPoints = <Offset>[];
    final clusterStrokeIds = <String>[];
    double maxRadius = 0;
    final assignedIds = <String>[];

    remainingStrokes.forEach((id, stroke) {
      if (stroke.points.isEmpty) return;

      // Check if stroke hits polygon (using manual check)
      if (!ConvexHullCalculator._strokeHitsPolygon(stroke, contour, rect)) {
        return;
      }

      clusterPoints.addAll(stroke.points.map((p) => p.position));
      clusterStrokeIds.add(id);
      maxRadius = math.max(
        maxRadius,
        ConvexHullCalculator._maxStrokeRadius(stroke),
      );
      assignedIds.add(id);
    });

    for (final id in assignedIds) {
      remainingStrokes.remove(id);
    }

    RotatedBoundingBox? box;
    if (clusterPoints.isNotEmpty) {
      box = ConvexHullCalculator.minimalBoundingBoxForPolygon(clusterPoints);
      if (box != null && maxRadius > 0) {
        box = box.expand(maxRadius);
      }

      if (box != null) {
        clustersDTO.add(
          _ClusterDataDTO(boundingBox: box, strokeIds: clusterStrokeIds),
        );
      }
    }
  }

  // Handle remaining strokes
  if (remainingStrokes.isNotEmpty) {
    for (final stroke in remainingStrokes.values) {
      if (stroke.points.isEmpty) continue;
      final points = stroke.points
          .map((p) => p.position)
          .toList(growable: false);
      RotatedBoundingBox? box =
          ConvexHullCalculator.minimalBoundingBoxForPolygon(points);
      if (box != null) {
        final maxRadius = ConvexHullCalculator._maxStrokeRadius(stroke);
        if (maxRadius > 0) box = box.expand(maxRadius);
        clustersDTO.add(
          _ClusterDataDTO(boundingBox: box, strokeIds: [stroke.id]),
        );
      }
    }
  }

  // Merge overlapping clusters (geometry only, so safe)
  bool merged = true;
  while (merged) {
    merged = false;
    for (var i = 0; i < clustersDTO.length; i++) {
      for (var j = i + 1; j < clustersDTO.length; j++) {
        if (clustersDTO[i].boundingBox.overlaps(clustersDTO[j].boundingBox)) {
          // Merge
          final newIds = [
            ...clustersDTO[i].strokeIds,
            ...clustersDTO[j].strokeIds,
          ];

          final allPoints = <Offset>[];
          double maxRadius = 0;
          for (final id in newIds) {
            final stroke = allStrokesMap[id];
            if (stroke != null) {
              allPoints.addAll(stroke.points.map((p) => p.position));
              maxRadius = math.max(
                maxRadius,
                ConvexHullCalculator._maxStrokeRadius(stroke),
              );
            }
          }

          RotatedBoundingBox? newBox =
              ConvexHullCalculator.minimalBoundingBoxForPolygon(allPoints);
          if (newBox != null) {
            if (maxRadius > 0) newBox = newBox.expand(maxRadius);
            clustersDTO[i] = _ClusterDataDTO(
              boundingBox: newBox,
              strokeIds: newIds,
            );
            clustersDTO.removeAt(j);
            merged = true;
            break;
          }
        }
      }
      if (merged) break;
    }
  }

  return _OverlayResultDTO(hulls: contours, clusters: clustersDTO);
}
