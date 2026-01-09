import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_painter.dart';

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
          painter: NotePaperPainter(
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
        painter: NotePaperPainter(
          style: paperStyle,
          lineColor: accentColor,
          importedPdfText: importedPdfText,
        ),
        child: child,
      ),
    );
  }
}
