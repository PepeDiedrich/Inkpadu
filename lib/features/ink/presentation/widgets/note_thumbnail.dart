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
    // ⚡ Bolt Optimization: Use cached bounding boxes to avoid O(P) iteration
    // Instead of iterating all points (P), we iterate strokes (S) which is much faster.
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in page.strokes) {
      final rect = stroke.boundingBox;
      if (rect.left < minX) minX = rect.left;
      if (rect.top < minY) minY = rect.top;
      if (rect.right > maxX) maxX = rect.right;
      if (rect.bottom > maxY) maxY = rect.bottom;
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

    // ⚡ Bolt Optimization: Wrap in RepaintBoundary to cache the rasterized thumbnail
    // This prevents expensive re-painting during scrolling when the thumbnail content is static.
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size, size),
        painter: _ThumbnailPainter(
          strokes: page.strokes,
          offsetX: -minX,
          offsetY: -minY,
          scale: scale,
          padding: padding,
        ),
      ),
    );
  }

  Widget _buildEmptyPreview(BuildContext context) => Center(
        child: Icon(
          Icons.draw_outlined,
          size: size * 0.4,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withValues(alpha: 0.5),
        ),
      );
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
      ..style = PaintingStyle.stroke; // Ensure we draw lines, not filled shapes

    // ⚡ Bolt Optimization: Reuse Path object to reduce GC pressure
    final path = Path();

    for (final stroke in strokes) {
      paint.color = stroke.isHighlighter
          ? stroke.color.withValues(alpha: stroke.color.a * 0.5)
          : stroke.color;

      if (stroke.points.length < 2) continue;

      // ⚡ Bolt Optimization: Use drawPath instead of many drawLine calls.
      // This reduces overhead significantly for thumbnails where variable width is less critical.
      path.reset();
      final points = stroke.points;
      path.moveTo(points[0].position.dx, points[0].position.dy);

      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].position.dx, points[i].position.dy);
      }

      // Use a constant width (approx. average pressure 0.5) for performance
      final width = (stroke.baseWidth * 0.5) * 0.8;
      paint.strokeWidth = width;
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThumbnailPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
