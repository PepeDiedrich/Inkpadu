import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Renders an inactive note page as a static preview.
///
/// Uses [CustomPaint] with [FinishedStrokesPainter] to display strokes
/// without interactive editing capabilities.
/// Uses [CustomPaint] with [FinishedStrokesPainter] to display strokes
/// without interactive editing capabilities.
class StaticNotePage extends StatefulWidget {
  /// Creates a static note page preview.
  const StaticNotePage({
    super.key,
    required this.page,
    required this.paperStyle,
    this.pdfDocument,
    this.pdfPageIndex,
  });

  /// The page data to render.
  final NotePage page;

  /// The paper style (grid, lines, blank).
  final NotePaperStyle paperStyle;

  /// Optional pre-loaded PDF document.
  final PdfDocument? pdfDocument;

  /// Optional PDF page index.
  final int? pdfPageIndex;

  static const double _initialCanvasHeight = 1600;
  static const double _canvasBottomPadding = 600;

  @override
  State<StaticNotePage> createState() => _StaticNotePageState();
}

class _StaticNotePageState extends State<StaticNotePage> {
  final StrokesPictureCache _pictureCache = StrokesPictureCache();

  @override
  void dispose() {
    _pictureCache.dispose();
    super.dispose();
  }

  double _requiredCanvasHeight() {
    var maxY = 0.0;
    for (final stroke in widget.page.strokes) {
      // ⚡ Bolt: Use pre-calculated boundingBox to find the max Y-coordinate
      // instead of iterating through every point. This reduces time complexity
      // from O(Strokes * Points) to O(Strokes).
      if (stroke.boundingBox.bottom > maxY) {
        maxY = stroke.boundingBox.bottom;
      }
    }
    return math.max(
      StaticNotePage._initialCanvasHeight,
      maxY + StaticNotePage._canvasBottomPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = _requiredCanvasHeight();
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: NotePaperBackground(
          paperStyle: widget.paperStyle,
          pdfDocument: widget.pdfDocument,
          pdfPageIndex: widget.pdfPageIndex,
          child: CustomPaint(
            painter: FinishedStrokesPainter(
              strokes: widget.page.strokes,
              cache: _pictureCache,
              version: Object.hash(
                widget.page.strokes.length,
                widget.page.hashCode,
              ),
              viewportRect: Rect.fromLTWH(
                0,
                0,
                MediaQuery.sizeOf(context).width,
                height,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
