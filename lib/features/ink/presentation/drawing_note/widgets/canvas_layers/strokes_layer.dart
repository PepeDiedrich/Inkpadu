import 'package:flutter/material.dart';
import 'package:inkpadu/features/drawing/application/drawing_controller.dart';
import 'package:inkpadu/features/drawing/presentation/drawing_painter.dart';

/// A widget layer that renders finished and currently drawn strokes.
class StrokesLayer extends StatelessWidget {
  /// Creates a [StrokesLayer].
  const StrokesLayer({
    super.key,
    required this.drawingController,
    required this.scrollController,
    required this.pictureCache,
    required this.getViewportRect,
  });

  /// The drawing controller managing the strokes.
  final DrawingController drawingController;

  /// The scroll controller of the canvas.
  final ScrollController scrollController;

  /// Cache for rendered stroke pictures.
  final StrokesPictureCache pictureCache;

  /// Determines the currently visible viewport.
  final Rect Function() getViewportRect;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      AnimatedBuilder(
        animation: Listenable.merge([scrollController, drawingController]),
        builder: (context, _) => RepaintBoundary(
          child: CustomPaint(
            painter: FinishedStrokesPainter(
              strokes: drawingController.strokes,
              cache: pictureCache,
              version: drawingController.strokesVersion,
              viewportRect: getViewportRect(),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: drawingController,
        builder: (context, _) => RepaintBoundary(
          child: CustomPaint(
            painter: CurrentStrokePainter(
              currentStroke: drawingController.currentStroke,
              pointCount: drawingController.currentStroke?.points.length ?? 0,
            ),
          ),
        ),
      ),
    ],
  );
}
