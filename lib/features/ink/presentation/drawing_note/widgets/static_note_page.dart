import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:flutter/material.dart';

/// Renders an inactive note page as a static preview.
///
/// Uses [CustomPaint] with [FinishedStrokesPainter] to display strokes
/// without interactive editing capabilities.
class StaticNotePage extends StatelessWidget {
  /// Creates a static note page preview.
  const StaticNotePage({
    super.key,
    required this.page,
    required this.paperStyle,
  });

  /// The page data to render.
  final NotePage page;

  /// The paper style (grid, lines, blank).
  final NotePaperStyle paperStyle;

  static const double _initialCanvasHeight = 1600;
  static const double _canvasBottomPadding = 600;

  double _requiredCanvasHeight() {
    var maxY = 0.0;
    for (final stroke in page.strokes) {
      for (final point in stroke.points) {
        if (point.position.dy > maxY) {
          maxY = point.position.dy;
        }
      }
    }
    return math.max(_initialCanvasHeight, maxY + _canvasBottomPadding);
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
          paperStyle: paperStyle,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: FinishedStrokesPainter(
                strokes: page.strokes,
                version: page.strokes.hashCode,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
