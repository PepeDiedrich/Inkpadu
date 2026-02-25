import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';

/// Helper class to render strokes to an image.
class StrokeRenderer {
  /// Renders a list of strokes to a base64 encoded PNG image.
  static Future<String?> renderStrokesToBase64(List<Stroke> strokes) async {
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

    // Draw strokes
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.isHighlighter) {
        paint.blendMode = BlendMode.multiply;
        paint.color = stroke.color.withValues(alpha: 0.5);
      }

      if (stroke.points.isEmpty) continue;

      if (stroke.points.length == 1) {
        paint.strokeWidth = stroke.baseWidth * stroke.points.first.pressure;
        canvas.drawPoints(
          ui.PointMode.points,
          [stroke.points.first.position],
          paint,
        );
        continue;
      }

      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        paint.strokeWidth = stroke.baseWidth * p1.pressure;
        canvas.drawLine(p1.position, p2.position, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return null;

    final bytes = byteData.buffer.asUint8List();
    return base64Encode(bytes);
  }
}
