import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';

/// Hintergrund der Zeichenfläche entsprechend des Papierstils.
class NotePaperBackground extends StatelessWidget {
  /// Erstellt eine neue Hintergrundhülle für die Zeichenfläche.
  const NotePaperBackground({
    super.key,
    required this.paperStyle,
    required this.child,
  });

  /// Stil, nach dem der Hintergrund gezeichnet wird.
  final NotePaperStyle paperStyle;

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
        child: child,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: baseColor),
      child: CustomPaint(
        painter: _NotePaperPainter(style: paperStyle, lineColor: accentColor),
        child: child,
      ),
    );
  }
}

class _NotePaperPainter extends CustomPainter {
  _NotePaperPainter({required this.style, required this.lineColor});

  final NotePaperStyle style;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
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

  void _paintLined(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const double spacing = 48;
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double spacing = 48;
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _paintDotted(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    const double spacing = 36;
    const double radius = 1.4;
    for (double y = 0; y <= size.height; y += spacing) {
      final double offset = (y ~/ spacing).isEven ? 0 : spacing / 2;
      for (double x = -offset; x <= size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NotePaperPainter oldDelegate) =>
      oldDelegate.style != style || oldDelegate.lineColor != lineColor;
}
