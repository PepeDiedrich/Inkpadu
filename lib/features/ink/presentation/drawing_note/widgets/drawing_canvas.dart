import 'dart:collection';
import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Zeichenfläche, die Eingaben an den [DrawingController] weiterleitet und
/// dynamisch in der Höhe wächst.
class DrawingCanvas extends StatefulWidget {
  /// Erstellt eine Zeichenfläche mit dem angegebenen Controller und Werkzeugen.
  const DrawingCanvas({
    super.key,
    required this.drawingController,
    required this.currentTool,
    required this.resolveTool,
    required this.eraserRadiusFor,
    required this.onPersistDrawing,
    this.initialCanvasHeight = 1600,
    this.canvasBottomPadding = 600,
  });

  /// Controller, der die Striche verwaltet.
  final DrawingController drawingController;

  /// Aktuell ausgewähltes Werkzeug.
  final DrawingTool currentTool;

  /// Callback zum Auflösen einer Werkzeug-ID.
  final DrawingTool Function(String? id) resolveTool;

  /// Berechnet den Radiererradius für ein Werkzeug.
  final double Function(DrawingTool tool) eraserRadiusFor;

  /// Wird aufgerufen, wenn eine Änderung persistiert werden soll.
  final VoidCallback onPersistDrawing;

  /// Mindesthöhe der Zeichenfläche.
  final double initialCanvasHeight;

  /// Zusätzlicher Puffer am unteren Rand.
  final double canvasBottomPadding;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late final ScrollController _canvasScrollController;
  late double _canvasHeight;
  double _lastScrollExpansionTrigger = -1;
  final Map<int, Offset> _activeTouchPositions = HashMap<int, Offset>();
  bool _isTwoFingerScrollActive = false;
  Offset? _lastTwoFingerFocalPoint;
  int? _activeDrawingPointerId;
  String? _activeToolDuringStrokeId;
  bool _didEraseDuringDrag = false;
  int _lastObservedVersion = 0;

  @override
  void initState() {
    super.initState();
    _canvasScrollController = ScrollController();
    _canvasHeight = _requiredCanvasHeightForStrokes(
      widget.drawingController.strokes,
    );
    _lastObservedVersion = widget.drawingController.strokesVersion;
    widget.drawingController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drawingController != widget.drawingController) {
      oldWidget.drawingController.removeListener(_handleControllerChanged);
      _lastObservedVersion = widget.drawingController.strokesVersion;
      widget.drawingController.addListener(_handleControllerChanged);
      _canvasHeight = _requiredCanvasHeightForStrokes(
        widget.drawingController.strokes,
      );
    } else if (oldWidget.currentTool.id != widget.currentTool.id) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.drawingController.removeListener(_handleControllerChanged);
    _canvasScrollController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    final int version = widget.drawingController.strokesVersion;
    if (version == _lastObservedVersion) {
      return;
    }
    _lastObservedVersion = version;
    final double requiredHeight = _requiredCanvasHeightForStrokes(
      widget.drawingController.strokes,
    );
    if (requiredHeight > _canvasHeight) {
      setState(() => _canvasHeight = requiredHeight);
    } else {
      setState(() {});
    }
  }

  double _requiredCanvasHeightForStrokes(List<Stroke> strokes) {
    var maxY = 0.0;
    for (final stroke in strokes) {
      for (final point in stroke.points) {
        final y = point.position.dy;
        if (y > maxY) {
          maxY = y;
        }
      }
    }
    return math.max(
      widget.initialCanvasHeight,
      maxY + widget.canvasBottomPadding,
    );
  }

  void _ensureCanvasHeightForPosition(double yPosition) {
    final requiredHeight = math.max(
      widget.initialCanvasHeight,
      yPosition + widget.canvasBottomPadding,
    );
    if (requiredHeight <= _canvasHeight) {
      return;
    }
    setState(() {
      _canvasHeight = requiredHeight;
    });
  }

  Offset? _computeTouchFocalPoint() {
    if (_activeTouchPositions.isEmpty) {
      return null;
    }
    var focal = Offset.zero;
    for (final position in _activeTouchPositions.values) {
      focal += position;
    }
    return focal / _activeTouchPositions.length.toDouble();
  }

  void _resetTwoFingerScrollState() {
    if (_activeTouchPositions.length < 2) {
      _isTwoFingerScrollActive = false;
      _lastTwoFingerFocalPoint = null;
    } else {
      _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
    }
  }

  void _abortDrawing() {
    if (_activeDrawingPointerId == null) {
      return;
    }
    final tool = widget.resolveTool(_activeToolDuringStrokeId);
    if (tool.isEraser) {
      _didEraseDuringDrag = false;
    } else {
      widget.drawingController.cancelCurrentStroke();
    }
    _activeDrawingPointerId = null;
    _activeToolDuringStrokeId = null;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final metrics = notification.metrics;
    if (metrics.extentAfter > widget.canvasBottomPadding * 0.5) {
      return false;
    }
    if (metrics.pixels <= _lastScrollExpansionTrigger + 1) {
      return false;
    }

    final double visibleExtent =
        metrics.pixels + metrics.viewportDimension + widget.canvasBottomPadding;
    if (visibleExtent <= _canvasHeight) {
      return false;
    }

    _lastScrollExpansionTrigger = metrics.pixels;
    setState(() {
      _canvasHeight = math.max(_canvasHeight, visibleExtent);
    });
    return false;
  }

  void _start(PointerDownEvent details) {
    final settings = PointerSettingsScope.of(context);
    final kind = details.kind;
    if (!settings.accept(kind)) return;

    if (kind == PointerDeviceKind.touch) {
      _activeTouchPositions[details.pointer] = details.localPosition;
      if (_activeTouchPositions.length >= 2) {
        _isTwoFingerScrollActive = true;
        _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
        _abortDrawing();
        return;
      }
    }

    settings.register(kind);

    final tool = widget.currentTool;
    _activeToolDuringStrokeId = tool.id;
    _didEraseDuringDrag = false;

    if (tool.isEraser) {
      _activeDrawingPointerId = details.pointer;
      final bool erased = _applyEraserPoint(details.localPosition, tool);
      if (erased) {
        _didEraseDuringDrag = true;
      }
      return;
    }

    final double pressure = _pressureForEvent(details, tool);
    final newPoint = DrawingPoint(
      position: details.localPosition,
      pressure: pressure,
    );

    _ensureCanvasHeightForPosition(newPoint.position.dy);

    widget.drawingController.startStroke(
      newPoint,
      color: tool.color,
      baseWidth: tool.baseWidth,
      isHighlighter: tool.isHighlighter,
    );
    _activeDrawingPointerId = details.pointer;
  }

  void _update(PointerMoveEvent details) {
    final kind = details.kind;

    if (kind == PointerDeviceKind.touch) {
      _activeTouchPositions[details.pointer] = details.localPosition;

      final int touchCount = _activeTouchPositions.length;
      if (touchCount >= 2 || _isTwoFingerScrollActive) {
        _isTwoFingerScrollActive = true;
        final Offset? focal = _computeTouchFocalPoint();
        if (focal != null) {
          if (_lastTwoFingerFocalPoint != null &&
              _canvasScrollController.hasClients) {
            final double delta = focal.dy - _lastTwoFingerFocalPoint!.dy;
            final double currentOffset = _canvasScrollController.offset;
            final double maxOffset =
                _canvasScrollController.position.maxScrollExtent;
            final double targetOffset = (currentOffset - delta).clamp(
              0.0,
              maxOffset,
            );
            if ((targetOffset - currentOffset).abs() > 0.01) {
              _canvasScrollController.jumpTo(targetOffset);
            }
          }
          _lastTwoFingerFocalPoint = focal;
        }
        return;
      }
    }

    if (_activeDrawingPointerId != details.pointer || !details.down) {
      return;
    }

    final tool = widget.resolveTool(_activeToolDuringStrokeId);

    if (tool.isEraser) {
      final bool erased = _applyEraserPoint(details.localPosition, tool);
      if (erased) {
        _didEraseDuringDrag = true;
      }
      return;
    }

    if (widget.drawingController.currentStroke == null) {
      return;
    }

    final double pressure = _pressureForEvent(details, tool);
    final newPoint = DrawingPoint(
      position: details.localPosition,
      pressure: pressure,
    );

    _ensureCanvasHeightForPosition(newPoint.position.dy);

    widget.drawingController.updateStroke(newPoint);
  }

  void _end(PointerUpEvent details) {
    if (details.kind == PointerDeviceKind.touch) {
      _activeTouchPositions.remove(details.pointer);
      _resetTwoFingerScrollState();
    }

    if (_activeDrawingPointerId != details.pointer) {
      return;
    }

    final tool = widget.resolveTool(_activeToolDuringStrokeId);
    _activeDrawingPointerId = null;
    _activeToolDuringStrokeId = null;

    if (tool.isEraser) {
      if (_didEraseDuringDrag) {
        widget.onPersistDrawing();
        _handleControllerChanged();
      }
      _didEraseDuringDrag = false;
      return;
    }

    _didEraseDuringDrag = false;

    final editorSettings = EditorSettingsScope.of(context);
    widget.drawingController.updateSimplifierSettings(
      strength: editorSettings.lineSimplifierStrength,
      minTolerance: editorSettings.lineSimplifierMinTolerance,
    );
    final bool simplify = editorSettings.lineSimplifierEnabled;
    widget.drawingController.endStroke(simplify: simplify).then((accepted) {
      if (accepted) {
        widget.onPersistDrawing();
        _handleControllerChanged();
      }
    });
  }

  void _cancel(PointerCancelEvent details) {
    if (details.kind == PointerDeviceKind.touch) {
      _activeTouchPositions.remove(details.pointer);
      _resetTwoFingerScrollState();
    }

    if (_activeDrawingPointerId == details.pointer) {
      final tool = widget.resolveTool(_activeToolDuringStrokeId);
      if (tool.isEraser) {
        _didEraseDuringDrag = false;
      } else {
        widget.drawingController.cancelCurrentStroke();
      }
      _activeDrawingPointerId = null;
      _activeToolDuringStrokeId = null;
    }
  }

  bool _applyEraserPoint(Offset position, DrawingTool tool) => widget
      .drawingController
      .eraseAt(position, radius: widget.eraserRadiusFor(tool));

  double _pressureForEvent(PointerEvent event, DrawingTool tool) {
    if (!tool.usePressure) {
      return 1;
    }
    final double pressure = event.pressure;
    if (!pressure.isFinite || pressure <= 0) {
      return 1;
    }
    final num clamped = pressure.clamp(0.1, 1.0);
    return clamped.toDouble();
  }

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
    behavior: const _DrawingScrollBehavior(),
    child: NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: SingleChildScrollView(
        controller: _canvasScrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          height: _canvasHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
            ),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _start,
              onPointerMove: _update,
              onPointerUp: _end,
              onPointerCancel: _cancel,
              child: AnimatedBuilder(
                animation: widget.drawingController,
                builder: (context, child) => Stack(
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: FinishedStrokesPainter(
                          strokes: widget.drawingController.strokes,
                          version: widget.drawingController.strokesVersion,
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: CurrentStrokePainter(
                          currentStroke: widget.drawingController.currentStroke,
                          pointCount:
                              widget
                                  .drawingController
                                  .currentStroke
                                  ?.points
                                  .length ??
                              0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DrawingScrollBehavior extends MaterialScrollBehavior {
  const _DrawingScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.mouse,
    PointerDeviceKind.unknown,
  };
}
