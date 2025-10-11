import 'dart:collection';
import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Berechnet enge Konturen um Strichdaten, indem die Zeichenfläche gerastert
/// und anschließend eine Kontur mittels Marching-Squares extrahiert wird.
class ConvexHullCalculator {
  const ConvexHullCalculator._();

  /// Erstellt Konturen für die gegebenen [strokes].
  ///
  /// [cellSize] bestimmt die Rasterauflösung (in Pixeln). Kleinere Werte führen
  /// zu präziseren, aber teureren Konturen. [padding] erweitert den betrachteten
  /// Bereich um die Striche, sodass der Rand nicht abgeschnitten wird. Mit
  /// [connectionMargin] kannst du steuern, wie stark nahe beieinander liegende
  /// Striche miteinander verschmelzen.
  static List<List<Offset>> contoursForStrokes(
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

    final double effectivePadding = math.max(padding, bounds.maxStrokeWidth);
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

    final double minStrokeRadius =
        math.max(_minimumStrokeRadius, cellSize * _minimumNodeRadiusFactor);

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
        _rasterizeSegment(
          segment,
          nodeGrid,
          origin,
          cellSize,
        );
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

    final List<List<Offset>> polygons = _segmentsToPolygons(
      segments,
      origin,
      cellSize,
    ).where((polygon) {
      final double area = _polygonArea(polygon);
      return area.abs() >= minimumArea;
    }).map((polygon) {
      final double tolerance = cellSize * simplifyToleranceFactor;
      return _simplifyPolygon(polygon, tolerance);
    }).where((polygon) => polygon.length >= 3).toList(growable: false);

    return polygons;
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
      _stampCircle(
        grid,
        origin,
        cellSize,
        position,
        segment.radius,
      );
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

  static List<_ContourPoint> _deduplicateContour(
    List<_ContourPoint> contour,
  ) {
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
        return <_EdgePair>[
          const _EdgePair(0, 3),
          const _EdgePair(1, 2),
        ];
      }
      if (mask == 10) {
        // Innenpunkte auf der Diagonalen oben rechts <-> unten links.
        return <_EdgePair>[
          const _EdgePair(0, 1),
          const _EdgePair(2, 3),
        ];
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

  static List<Offset> _simplifyPolygon(
    List<Offset> polygon,
    double tolerance,
  ) {
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

  static double _perpendicularDistance(
    Offset point,
    Offset start,
    Offset end,
  ) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    if (dx == 0 && dy == 0) {
      return (point - start).distance;
    }
    final double numerator = ((point.dx - start.dx) * dy -
            (point.dy - start.dy) * dx)
        .abs();
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
const double _defaultConnectionMargin = 12;
const double _minimumNodeRadiusFactor = 0.6;

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
