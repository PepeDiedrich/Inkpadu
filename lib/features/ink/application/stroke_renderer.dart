import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';

/// Repräsentiert das Ergebnis eines gerenderten Bildes.
class RenderedImageResult {
  /// Erstellt ein neues [RenderedImageResult].
  RenderedImageResult(this.base64Image, this.bounds);

  /// Das gerenderte Bild als Base64-String.
  final String base64Image;

  /// Die Begrenzungen des gerenderten Bildes.
  final Rect bounds;
}

/// Helper class to render strokes to an image.
class StrokeRenderer {
  /// Renders a list of strokes to a base64 encoded PNG image.
  static Future<String?> renderStrokesToBase64(List<Stroke> strokes) async {
    final result = await renderStrokesToImageResult(strokes);
    return result?.base64Image;
  }

  /// Renders a list of strokes to a base64 encoded PNG image and returns the bounds.
  static Future<RenderedImageResult?> renderStrokesToImageResult(
    List<Stroke> strokes,
  ) async {
    if (strokes.isEmpty) return null;

    // Calculate bounding box of all strokes
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in strokes) {
      final bounds = stroke.boundingBox;
      if (bounds.left < minX) minX = bounds.left;
      if (bounds.top < minY) minY = bounds.top;
      if (bounds.right > maxX) maxX = bounds.right;
      if (bounds.bottom > maxY) maxY = bounds.bottom;
    }

    if (minX == double.infinity) return null;

    // Add some padding
    const padding = 20.0;
    minX -= padding;
    minY -= padding;
    maxX += padding;
    maxY += padding;

    final width = maxX - minX;
    final height = maxY - minY;

    if (width <= 0 || height <= 0) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Fill background with white
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.white,
    );

    // Translate canvas so strokes are drawn at the origin
    canvas.translate(-minX, -minY);

    // Draw strokes with pen-type awareness
    for (final stroke in strokes) {
      final bool isMarker = stroke.penType == PenType.marker;
      final paint = Paint()
        ..color = isMarker
            ? stroke.color.withValues(alpha: 0.45)
            : stroke.color
        ..strokeCap = isMarker ? StrokeCap.square : StrokeCap.round
        ..strokeJoin = isMarker ? StrokeJoin.bevel : StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.baseWidth;

      if (stroke.points.isEmpty) continue;

      if (stroke.points.length == 1) {
        canvas.drawPoints(ui.PointMode.points, [
          stroke.points.first.position,
        ], paint);
        continue;
      }

      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        canvas.drawLine(p1.position, p2.position, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return null;

    final bytes = byteData.buffer.asUint8List();
    return RenderedImageResult(
      base64Encode(bytes),
      Rect.fromLTWH(minX, minY, width, height),
    );
  }
}
