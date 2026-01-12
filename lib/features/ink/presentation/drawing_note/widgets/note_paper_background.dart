import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';

/// Hintergrund der Zeichenfläche entsprechend des Papierstils.
class NotePaperBackground extends StatelessWidget {
  /// Erstellt eine neue Hintergrundhülle für die Zeichenfläche.
  const NotePaperBackground({
    super.key,
    required this.paperStyle,
    required this.child,
    this.importedPdfText,
  });

  /// Stil, nach dem der Hintergrund gezeichnet wird.
  final NotePaperStyle paperStyle;

  /// Optionaler Text aus einem importierten PDF.
  final String? importedPdfText;

  /// Zeichenfläche, die oberhalb des Papiermusters dargestellt wird.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color baseColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.15,
    );
    final Color accentColor = colorScheme.outlineVariant.withValues(alpha: 0.5);

    if (paperStyle == NotePaperStyle.plain) {
      return DecoratedBox(
        decoration: BoxDecoration(color: baseColor),
        child: CustomPaint(
          painter: _NotePaperPainter(
            style: paperStyle,
            lineColor: accentColor,
            importedPdfText: importedPdfText,
          ),
          child: child,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: baseColor),
      child: CustomPaint(
        painter: _NotePaperPainter(
          style: paperStyle,
          lineColor: accentColor,
          importedPdfText: importedPdfText,
        ),
        child: child,
      ),
    );
  }
}

class _NotePaperPainter extends CustomPainter {
  _NotePaperPainter({
    required this.style,
    required this.lineColor,
    this.importedPdfText,
  });

  final NotePaperStyle style;
  final Color lineColor;
  final String? importedPdfText;

  @override
  void paint(Canvas canvas, Size size) {
    if (importedPdfText != null && importedPdfText!.isNotEmpty) {
      _paintImportedText(canvas, size);
    }

    switch (style) {
      case NotePaperStyle.plain:
        return;
      case NotePaperStyle.lined:
        _paintLined(canvas, size);
        break;
      case NotePaperStyle.grid:
        _paintGrid(canvas, size);
        break;
      case NotePaperStyle.dotted:
        _paintDotted(canvas, size);
        break;
    }
  }

  void _paintImportedText(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: importedPdfText,
      style: TextStyle(
        color: lineColor.withValues(alpha: 0.8),
        fontSize: 16,
        height: 1.4,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    const padding = 24.0;
    final maxWidth = size.width - (padding * 2);

    textPainter.layout(maxWidth: maxWidth);
    textPainter.paint(canvas, const Offset(padding, padding));
  }

  // ⚡ Bolt Optimization: Use drawPath instead of repeated drawLine
  void _paintLined(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    const double spacing = 48;
    for (double y = 0; y <= size.height; y += spacing) {
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }
    canvas.drawPath(path, paint);
  }

  // ⚡ Bolt Optimization: Use drawPath instead of repeated drawLine
  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    const double spacing = 48;
    for (double y = 0; y <= size.height; y += spacing) {
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }
    for (double x = 0; x <= size.width; x += spacing) {
      path.moveTo(x, 0);
      path.lineTo(x, size.height);
    }
    canvas.drawPath(path, paint);
  }

  // ⚡ Bolt Optimization: Use drawRawPoints instead of repeated drawCircle
  void _paintDotted(Canvas canvas, Size size) {
    const double spacing = 36;
    const double radius = 1.4;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = radius * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    // Use Float32List for lower memory overhead and raw drawing performance
    final List<double> points = [];

    for (double y = 0; y <= size.height; y += spacing) {
      final double offset = (y ~/ spacing).isEven ? 0 : spacing / 2;
      for (double x = -offset; x <= size.width; x += spacing) {
        points.add(x);
        points.add(y);
      }
    }

    final rawPoints = Float32List.fromList(points);
    canvas.drawRawPoints(ui.PointMode.points, rawPoints, paint);
  }

  @override
  bool shouldRepaint(covariant _NotePaperPainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.importedPdfText != importedPdfText;
}
