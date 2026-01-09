import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';

/// Painter für das Hintergrundmuster (Liniert, Kariert, etc.).
class NotePaperPainter extends CustomPainter {
  /// Erstellt einen neuen [NotePaperPainter].
  NotePaperPainter({
    required this.style,
    required this.lineColor,
    this.importedPdfText,
  });

  /// Der zu zeichnende Papierstil.
  final NotePaperStyle style;

  /// Farbe der Linien oder Punkte.
  final Color lineColor;

  /// Optionaler PDF-Text, der im Hintergrund angezeigt wird.
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
  bool shouldRepaint(covariant NotePaperPainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.importedPdfText != importedPdfText;
}
