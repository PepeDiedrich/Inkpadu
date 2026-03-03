import 'dart:ui' as ui;

import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Gemeinsame Low-Level Routine zum Zeichnen eines einzelnen [Stroke].
void _paintStroke(Canvas canvas, Stroke stroke) {
  if (stroke.points.isEmpty) return;

  final paint = Paint()
    ..color = stroke.isHighlighter
        ? stroke.color.withValues(alpha: stroke.color.a * 0.5)
        : stroke.color
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke
    ..strokeWidth = stroke.baseWidth;

  if (stroke.points.length == 1) {
    canvas.drawCircle(
      stroke.points.first.position,
      stroke.baseWidth / 2,
      paint..style = PaintingStyle.fill,
    );
    return;
  }

  if (stroke.cachedPath != null) {
    canvas.drawPath(stroke.cachedPath!, paint);
    return;
  }

  final path = stroke.generatePath();
  if (path != null) {
    stroke.cachedPath = path;
    canvas.drawPath(path, paint);
  }
}

/// Malt alle abgeschlossenen Striche. Repaint nur wenn sich die Version ändert.
class FinishedStrokesPainter extends CustomPainter {
  /// Erstellt einen Painter für bereits abgeschlossene Striche.
  FinishedStrokesPainter({
    required List<Stroke> strokes,
    required this.cache,
    required this.version,
    required this.viewportRect,
  }) : strokes = List<Stroke>.unmodifiable(strokes);

  /// Alle abgeschlossenen Striche auf der Seite.
  final List<Stroke> strokes;

  /// Cache object to hold the rendered picture.
  final StrokesPictureCache cache;

  /// Version der Strichliste. Erhöht sich bei jeder strukturellen Änderung
  /// (Undo, Redo, Clear, Abschluss eines Strichs). Dient für shouldRepaint.
  final int version;

  /// Das Rechteck des aktuell sichtbaren Viewports für Culling.
  final Rect viewportRect;

  /// Zeichnet alle abgeschlossenen Striche auf die Leinwand.
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Purge old tiles to free memory.
    cache.purgeOutside(viewportRect);

    // 2. Determine visible tiles.
    final startX = (viewportRect.left / StrokesPictureCache.tileSize).floor();
    final startY = (viewportRect.top / StrokesPictureCache.tileSize).floor();
    final endX = (viewportRect.right / StrokesPictureCache.tileSize).ceil();
    final endY = (viewportRect.bottom / StrokesPictureCache.tileSize).ceil();

    // 3. Render and draw tiles.
    for (int y = startY; y < endY; y++) {
      for (int x = startX; x < endX; x++) {
        final tile = cache.getTile(x, y);

        if (tile.version != version || tile.picture == null) {
          final tileLeft = x * StrokesPictureCache.tileSize;
          final tileTop = y * StrokesPictureCache.tileSize;
          final tileRect = Rect.fromLTWH(
            tileLeft,
            tileTop,
            StrokesPictureCache.tileSize,
            StrokesPictureCache.tileSize,
          );

          final recorder = ui.PictureRecorder();
          final recordCanvas = Canvas(recorder, tileRect);

          recordCanvas.save();
          recordCanvas.clipRect(tileRect);

          // Render only strokes that intersect this tile.
          for (final stroke in strokes) {
            if (stroke.boundingBox.overlaps(tileRect)) {
              _paintStroke(recordCanvas, stroke);
            }
          }

          recordCanvas.restore();

          tile.picture?.dispose();
          tile.picture = recorder.endRecording();
          tile.version = version;
        }

        if (tile.picture != null) {
          canvas.drawPicture(tile.picture!);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant FinishedStrokesPainter oldDelegate) =>
      oldDelegate.version != version ||
      oldDelegate.viewportRect != viewportRect;
}

/// A cache object for a single tile.
class TileCache {
  /// The cached rendered picture.
  ui.Picture? picture;

  /// The version of the strokes this picture represents.
  int version = -1;

  /// Cleans up resources held by the picture cache.
  void dispose() {
    picture?.dispose();
    picture = null;
    version = -1;
  }
}

/// A cache object to hold offscreen rendered pictures of strokes, divided into tiles.
class StrokesPictureCache {
  /// Defines the visual size of a single tile (e.g., 1000x1000).
  static const double tileSize = 1000.0;

  /// Map of tile coordinates (x, y) to their cached pictures.
  final Map<(int, int), TileCache> _tiles = {};

  /// Cleans up resources held by the picture cache.
  void dispose() {
    for (final tile in _tiles.values) {
      tile.dispose();
    }
    _tiles.clear();
  }

  /// Returns the cache for a specific tile, creating it if necessary.
  TileCache getTile(int x, int y) =>
      _tiles.putIfAbsent((x, y), () => TileCache());

  /// Removes tiles that are far outside the current viewport to free up memory.
  void purgeOutside(Rect viewportRect) {
    // Keep a margin of 1 tile around the viewport.
    final keepRect = viewportRect.inflate(tileSize);
    _tiles.removeWhere((index, tile) {
      final tileX = index.$1 * tileSize;
      final tileY = index.$2 * tileSize;
      final tileRect = Rect.fromLTWH(tileX, tileY, tileSize, tileSize);
      if (!keepRect.overlaps(tileRect)) {
        tile.dispose();
        return true;
      }
      return false;
    });
  }
}

/// Malt den aktuell entstehenden Strich. Repaint nur bei neuem Objekt oder
/// veränderter Punktzahl (wächst während des Zeichnens).
class CurrentStrokePainter extends CustomPainter {
  /// Erstellt einen Painter für den aktuell entstehenden Strich.
  CurrentStrokePainter({required this.currentStroke, required this.pointCount});

  /// Der aktuell gezeichnete, noch nicht abgeschlossene Strich.
  final Stroke? currentStroke;

  /// Aktuelle Anzahl der Punkte im Strich. Wächst während des Zeichnens.
  final int pointCount;

  /// Zeichnet den aktuell entstehenden Strich auf die Leinwand.
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = currentStroke;
    if (stroke == null) return;
    _paintStroke(canvas, stroke);
  }

  @override
  bool shouldRepaint(covariant CurrentStrokePainter oldDelegate) =>
      oldDelegate.currentStroke != currentStroke ||
      oldDelegate.pointCount != pointCount;
}
