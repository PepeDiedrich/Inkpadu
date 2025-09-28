import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'stroke_simplifier.dart' show simplifyStrokePoints; // Reuse existing point simplification
import '../domain/stroke.dart';
import '../domain/drawing_point.dart';

/// Asynchrone Vereinfachung eines [Stroke] mittels Isolate über [compute].
///
/// Nutzt denselben Ramer-Douglas-Peucker Algorithmus wie `simplifyStroke`,
/// führt ihn aber in einem separaten Isolate aus, wenn die Punktanzahl den
/// [threshold] überschreitet, um UI-Jank zu vermeiden.
///
/// Fällt automatisch auf synchrone Vereinfachung zurück, wenn:
/// - Die Punktanzahl kleiner als [threshold] ist
/// - Wir uns auf dem Web befinden (Isolate Overhead lohnt sich selten) oder
/// - `kDebugMode` und sehr kurze Striche (Overhead höher als Benefit)
Future<Stroke> simplifyStrokeAsync(
  Stroke stroke, {
  double tolerance = 1.0,
  int threshold = 250,
}) async {
  if (stroke.points.length < threshold || kIsWeb) {
    // Geringe Punktzahl: direkt synchron vereinfachen.
    final simplified = simplifyStrokePoints(stroke.points, tolerance: tolerance);
    return stroke.copyWith(points: simplified);
  }
  final payload = _SimplifyPayload(
    tolerance: tolerance,
    color: stroke.color.value,
    width: stroke.baseWidth,
    isHighlighter: stroke.isHighlighter,
    id: stroke.id,
    points: stroke.points
        .map((p) => _PointDTO(x: p.position.dx, y: p.position.dy, p: p.pressure))
        .toList(growable: false),
  );
  final result = await compute<_SimplifyPayload, _SimplifyResult>(
    _simplifyIsolate,
    payload,
  );
  return Stroke(
    id: result.id,
    points: result.points
        .map((d) => DrawingPoint(position: Offset(d.x, d.y), pressure: d.p))
        .toList(growable: false),
    color: Color(result.color),
    baseWidth: result.width,
    isHighlighter: result.isHighlighter,
  );
}

class _PointDTO {
  const _PointDTO({required this.x, required this.y, required this.p});
  final double x;
  final double y;
  final double p;
}

class _SimplifyPayload {
  const _SimplifyPayload({
    required this.points,
    required this.tolerance,
    required this.color,
    required this.width,
    required this.isHighlighter,
    required this.id,
  });
  final List<_PointDTO> points;
  final double tolerance;
  final int color;
  final double width;
  final bool isHighlighter;
  final String id;
}

class _SimplifyResult {
  const _SimplifyResult({
    required this.points,
    required this.color,
    required this.width,
    required this.isHighlighter,
    required this.id,
  });
  final List<_PointDTO> points;
  final int color;
  final double width;
  final bool isHighlighter;
  final String id;
}

_SimplifyResult _simplifyIsolate(_SimplifyPayload payload) {
  final points = payload.points
      .map((d) => DrawingPoint(position: Offset(d.x, d.y), pressure: d.p))
      .toList(growable: false);
  final simplified = simplifyStrokePoints(points, tolerance: payload.tolerance);
  final dto = simplified
      .map((p) => _PointDTO(x: p.position.dx, y: p.position.dy, p: p.pressure))
      .toList(growable: false);
  return _SimplifyResult(
    points: dto,
    color: payload.color,
    width: payload.width,
    isHighlighter: payload.isHighlighter,
    id: payload.id,
  );
}
