import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:flutter/material.dart';

/// A widget that paints only the finished strokes.
///
/// It listens to the [DrawingController] but only triggers a rebuild
/// when [DrawingController.strokesVersion] changes (e.g., when a stroke is
/// finished, undone, or cleared). It ignores updates during active drawing
/// (dragging) to improve performance.
class FinishedStrokesLayer extends StatefulWidget {
  /// Creates a layer for finished strokes.
  const FinishedStrokesLayer({super.key, required this.controller});

  /// The drawing controller to listen to.
  final DrawingController controller;

  @override
  State<FinishedStrokesLayer> createState() => _FinishedStrokesLayerState();
}

class _FinishedStrokesLayerState extends State<FinishedStrokesLayer> {
  late int _version;

  @override
  void initState() {
    super.initState();
    _version = widget.controller.strokesVersion;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant FinishedStrokesLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      _version = widget.controller.strokesVersion;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    // Only rebuild if the structural version of strokes has changed.
    // This ignores updates during active drawing (dragging).
    if (widget.controller.strokesVersion != _version) {
      setState(() {
        _version = widget.controller.strokesVersion;
      });
    }
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          painter: FinishedStrokesPainter(
            strokes: widget.controller.strokes,
            version: _version,
          ),
        ),
      );
}

/// A widget that paints only the current stroke being drawn.
///
/// It listens to the [DrawingController] and rebuilds on every notification
/// to show the stroke in real-time. Using a separate layer prevents the
/// finished strokes layer from rebuilding during drag.
class CurrentStrokeLayer extends StatelessWidget {
  /// Creates a layer for the current stroke.
  const CurrentStrokeLayer({super.key, required this.controller});

  /// The drawing controller to listen to.
  final DrawingController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final currentStroke = controller.currentStroke;
          return RepaintBoundary(
            child: CustomPaint(
              painter: CurrentStrokePainter(
                currentStroke: currentStroke,
                pointCount: currentStroke?.points.length ?? 0,
              ),
            ),
          );
        },
      );
}
