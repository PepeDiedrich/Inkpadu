import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:flutter/material.dart';

/// Widget that renders a compact thumbnail preview of a note page.
///
/// Displays a scaled-down version of the note's first page strokes
/// with the paper style color as accent.
class NoteThumbnail extends StatelessWidget {
  /// Creates a note thumbnail preview.
  const NoteThumbnail({
    super.key,
    required this.page,
    required this.paperStyle,
    this.size = 64.0,
  });

  /// The page to render in the thumbnail.
  final NotePage page;

  /// The paper style for color accent.
  final NotePaperStyle paperStyle;

  /// The size of the thumbnail (square).
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasStrokes = page.strokes.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: hasStrokes
            ? _buildStrokesPreview(context)
            : _buildEmptyPreview(context),
      ),
    );
  }

  Widget _buildStrokesPreview(BuildContext context) {
    // Calculate bounding box to scale strokes appropriately
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in page.strokes) {
      for (final point in stroke.points) {
        if (point.position.dx < minX) minX = point.position.dx;
        if (point.position.dy < minY) minY = point.position.dy;
        if (point.position.dx > maxX) maxX = point.position.dx;
        if (point.position.dy > maxY) maxY = point.position.dy;
      }
    }

    final contentWidth = maxX - minX;
    final contentHeight = maxY - minY;

    // Avoid division by zero
    if (contentWidth <= 0 || contentHeight <= 0) {
      return _buildEmptyPreview(context);
    }

    // Calculate scale to fit content in thumbnail with padding
    final padding = size * 0.1;
    final availableSize = size - (padding * 2);
    final scale = (availableSize / contentWidth).clamp(
      0.0,
      availableSize / contentHeight,
    );

    return CustomPaint(
      size: Size(size, size),
      painter: _ThumbnailPainter(
        strokes: page.strokes,
        offsetX: -minX,
        offsetY: -minY,
        scale: scale,
        padding: padding,
      ),
    );
  }

  Widget _buildEmptyPreview(BuildContext context) {
    return Center(
      child: Icon(
        Icons.draw_outlined,
        size: size * 0.4,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
}

/// Custom painter that renders scaled strokes for the thumbnail.
class _ThumbnailPainter extends CustomPainter {
  _ThumbnailPainter({
    required this.strokes,
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.padding,
  });

  final List<Stroke> strokes;
  final double offsetX;
  final double offsetY;
  final double scale;
  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(padding, padding);
    canvas.scale(scale);
    canvas.translate(offsetX, offsetY);

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      paint.color = stroke.isHighlighter
          ? stroke.color.withOpacity(stroke.color.opacity * 0.5)
          : stroke.color;

      if (stroke.points.isEmpty) continue;

      for (var i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        // Use a thinner stroke for thumbnail
        final width =
            (stroke.baseWidth * (p1.pressure + p2.pressure) / 2) * 0.8;
        paint.strokeWidth = width;
        canvas.drawLine(p1.position, p2.position, paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThumbnailPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
