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
    // Calculate bounding box using cached Stroke properties (O(N) instead of O(TotalPoints))
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
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      paint.color = stroke.isHighlighter
          ? stroke.color.withValues(alpha: stroke.color.a * 0.5)
          : stroke.color;

      // Optimization: Use drawPath instead of many drawLine calls.
      // We calculate an average width for the stroke since variable pressure
      // is hardly visible at thumbnail scale.

      final path = Path();
      path.moveTo(stroke.points.first.position.dx, stroke.points.first.position.dy);

      double totalPressure = 0.0;
      for (int i = 1; i < stroke.points.length; i++) {
        final p = stroke.points[i];
        path.lineTo(p.position.dx, p.position.dy);
        totalPressure += p.pressure;
      }

      final avgPressure = stroke.points.length > 1
          ? totalPressure / (stroke.points.length - 1)
          : stroke.points.first.pressure;

      // Use a thinner stroke for thumbnail (0.8 factor from original code)
      paint.strokeWidth = (stroke.baseWidth * avgPressure) * 0.8;

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ThumbnailPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
