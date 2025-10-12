import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart';
import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:flutter/foundation.dart';
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
    required this.onTwoFingerUndo,
    required this.paperStyle,
    this.scrollKey,
    this.initScrollOffset,
    this.onScrollOffsetChanged,
    this.initialCanvasHeight = 1600,
    this.canvasBottomPadding = 600,
    this.onRequestParentScrollLock,
    this.onStrokeClustersChanged,
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

  /// Wird ausgelöst, wenn die Zwei-Finger-Tap-Geste erkannt wurde.
  final VoidCallback onTwoFingerUndo;

  /// Bestimmt den visuellen Hintergrund der Zeichenfläche.
  final NotePaperStyle paperStyle;

  /// Optionaler Key (z. B. PageStorageKey), um die Scrollposition zu speichern.
  final Key? scrollKey;

  /// Optionaler initialer Scroll-Offset, der beim ersten Build gesetzt wird.
  final double? initScrollOffset;

  /// Optionaler Callback, der bei Scroll-Änderungen den aktuellen Offset liefert.
  final ValueChanged<double>? onScrollOffsetChanged;

  /// Mindesthöhe der Zeichenfläche.
  final double initialCanvasHeight;

  /// Zusätzlicher Puffer am unteren Rand.
  final double canvasBottomPadding;

  /// Optionaler Callback: true = Parent soll horizontales Scrollen sperren.
  /// Wird aufgerufen mit `true` wenn eine Zeichenaktion startet und mit `false`
  /// wenn sie endet oder abgebrochen wird.
  final ValueChanged<bool>? onRequestParentScrollLock;

  /// Optionaler Callback, der über aktualisierte Stroke-Cluster informiert.
  final ValueChanged<List<StrokeBoundingBoxCluster>>?
      onStrokeClustersChanged;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late final ScrollController _canvasScrollController;
  late double _canvasHeight;
  double? _desiredInitialOffset;
  double _lastScrollExpansionTrigger = -1;
  final Map<int, Offset> _activeTouchPositions = HashMap<int, Offset>();
  static const Duration _twoFingerTapMaxDuration = Duration(milliseconds: 260);
  static const double _twoFingerTapMaxMovement = 22;
  static const Duration _hullDebounceDuration = Duration(milliseconds: 500);
  
  DateTime? _twoFingerTapStart;
  final Map<int, Offset> _twoFingerTapInitialPositions = <int, Offset>{};
  bool _isTwoFingerScrollActive = false;
  Offset? _lastTwoFingerFocalPoint;
  int? _activeDrawingPointerId;
  String? _activeToolDuringStrokeId;
  bool _didEraseDuringDrag = false;
  int _lastObservedVersion = 0;
  Timer? _hullDebounceTimer;
  List<List<Offset>> _convexHulls = const [];
  List<RotatedBoundingBox> _boundingBoxes = const <RotatedBoundingBox>[];
  List<StrokeBoundingBoxCluster> _strokeClusters =
      const <StrokeBoundingBoxCluster>[];

  @override
  void initState() {
    super.initState();
  _canvasScrollController = ScrollController();
    _canvasHeight = _requiredCanvasHeightForStrokes(
      widget.drawingController.strokes,
    );
    _lastObservedVersion = widget.drawingController.strokesVersion;
    widget.drawingController.addListener(_handleControllerChanged);

    // Falls ein initialer Scroll-Offset übergeben wurde, setze ihn
    // nach dem ersten Frame (damit Größe/Constraints stehen).
    if (widget.initScrollOffset != null) {
      _desiredInitialOffset = widget.initScrollOffset;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_canvasScrollController.hasClients) return;
        final double target = widget.initScrollOffset!.clamp(0.0, _canvasScrollController.position.maxScrollExtent);
        _canvasScrollController.jumpTo(target);
      });
    }
    _notifyDrawingActivity();
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
      // reset any gesture-related state
    } else if (oldWidget.currentTool.id != widget.currentTool.id) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _hullDebounceTimer?.cancel();
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
      // Nach Höhenzuwachs ggf. den gewünschten Start-Offset anwenden
      if (_desiredInitialOffset != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_canvasScrollController.hasClients) return;
          final double target = _desiredInitialOffset!.clamp(0.0, _canvasScrollController.position.maxScrollExtent);
          if ((_canvasScrollController.offset - target).abs() > 1) {
            _canvasScrollController.jumpTo(target);
          }
        });
      }
    } else {
      setState(() {});
    }
    _notifyDrawingActivity();
  }

  void _notifyDrawingActivity() {
    _hullDebounceTimer?.cancel();
    _hullDebounceTimer = Timer(
      _hullDebounceDuration,
      _rebuildConvexHulls,
    );
  }

  void _rebuildConvexHulls() {
    if (!mounted) {
      return;
    }
    final List<Stroke> allStrokes = List<Stroke>.of(
      widget.drawingController.strokes,
    );
    final Stroke? currentStroke = widget.drawingController.currentStroke;
    if (currentStroke != null && currentStroke.points.length >= 2) {
      allStrokes.add(currentStroke);
    }
  final List<List<Offset>> hulls =
      ConvexHullCalculator.contoursForStrokes(allStrokes);
  final List<StrokeBoundingBoxCluster> clusters =
      ConvexHullCalculator.clustersForContours(hulls, allStrokes);
  final List<RotatedBoundingBox> boxes = clusters
      .map((cluster) => cluster.boundingBox)
      .toList(growable: false);
    if (_hullsEqual(_convexHulls, hulls) &&
        _boxesEqual(_boundingBoxes, boxes) &&
        _clustersEqual(_strokeClusters, clusters)) {
      return;
    }
    setState(() {
      _convexHulls = hulls;
      _boundingBoxes = boxes;
      _strokeClusters = clusters;
    });
    widget.onStrokeClustersChanged?.call(clusters);
  }

  bool _hullsEqual(List<List<Offset>> a, List<List<Offset>> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!listEquals(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }

  bool _boxesEqual(
    List<RotatedBoundingBox> a,
    List<RotatedBoundingBox> b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!listEquals(a[i].corners, b[i].corners)) {
        return false;
      }
    }
    return true;
  }

  bool _clustersEqual(
    List<StrokeBoundingBoxCluster> a,
    List<StrokeBoundingBoxCluster> b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
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

  // pinch distance calculation removed (no pinch-to-zoom)

  void _resetTwoFingerScrollState() {
    if (_activeTouchPositions.length < 2) {
      _clearTwoFingerGestureState();
    } else {
      _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
      // keep track of focal point for two-finger scroll
    }
  }

  void _beginTwoFingerTapCandidate() {
    _twoFingerTapStart = DateTime.now();
    _twoFingerTapInitialPositions
      ..clear()
      ..addAll(_activeTouchPositions);
    _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
    _setTwoFingerScrollActive(false);
    // initialize two-finger tap candidate
  }

  void _cancelTwoFingerTapCandidate() {
    _twoFingerTapStart = null;
    _twoFingerTapInitialPositions.clear();
  }

  bool _isTwoFingerTapMovementWithinThreshold() {
    if (_twoFingerTapStart == null || _twoFingerTapInitialPositions.isEmpty) {
      return false;
    }
    final double maxSquared =
        _twoFingerTapMaxMovement * _twoFingerTapMaxMovement;
    for (final entry in _twoFingerTapInitialPositions.entries) {
      final Offset? current = _activeTouchPositions[entry.key];
      if (current == null) {
        continue;
      }
      final double dx = current.dx - entry.value.dx;
      final double dy = current.dy - entry.value.dy;
      if ((dx * dx + dy * dy) > maxSquared) {
        return false;
      }
    }
    return true;
  }

  bool _isTwoFingerTapWithinTimeWindow() {
    if (_twoFingerTapStart == null) {
      return false;
    }
    return DateTime.now().difference(_twoFingerTapStart!) <=
        _twoFingerTapMaxDuration;
  }

  void _triggerTwoFingerUndo() {
    _clearTwoFingerGestureState();
    Feedback.forTap(context);
    widget.onTwoFingerUndo();
  }

  void _clearTwoFingerGestureState() {
    _setTwoFingerScrollActive(false);
    _lastTwoFingerFocalPoint = null;
    _cancelTwoFingerTapCandidate();
    // clear pinch/initial distance state (pinch removed)
  }

  void _setTwoFingerScrollActive(bool value) {
    if (_isTwoFingerScrollActive == value) {
      return;
    }
    _isTwoFingerScrollActive = value;
    if (value) {
      // prepare two-finger scroll; no pinch handling
    }
  }

  // Pinch-to-zoom has been removed. Two-finger scroll and two-finger-tap remain.

  void _abortDrawing() {
    if (_activeDrawingPointerId == null) {
      return;
    }
    final tool = widget.resolveTool(_activeToolDuringStrokeId);
    if (tool.isEraser) {
      _didEraseDuringDrag = false;
    } else {
      widget.drawingController.cancelCurrentStroke();
      // Inform parent that drawing ended/was aborted
      widget.onRequestParentScrollLock?.call(false);
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

    // Nach einer Expansion die zuletzt gewünschte Position (falls vom Aufrufer gesetzt)
    // bestmöglich wiederherstellen.
    if (widget.initScrollOffset != null && _canvasScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_canvasScrollController.hasClients) return;
        final double target = widget.initScrollOffset!.clamp(0.0, _canvasScrollController.position.maxScrollExtent);
        if ((_canvasScrollController.offset - target).abs() > 1) {
          _canvasScrollController.jumpTo(target);
        }
      });
    }
    return false;
  }

  void _start(PointerDownEvent details) {
    final settings = PointerSettingsScope.of(context);
    final kind = details.kind;
    bool touchAllowsDrawing = true;

    if (kind == PointerDeviceKind.touch) {
      _activeTouchPositions[details.pointer] = details.localPosition;
      if (_activeTouchPositions.length > 2) {
        _cancelTwoFingerTapCandidate();
        _setTwoFingerScrollActive(true);
        _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
        _abortDrawing();
        touchAllowsDrawing = false;
      } else if (_activeTouchPositions.length == 2) {
        _beginTwoFingerTapCandidate();
        _abortDrawing();
        touchAllowsDrawing = false;
      }

      if (!touchAllowsDrawing && !settings.accept(kind)) {
        return;
      }
      if (!touchAllowsDrawing) {
        return;
      }
    }

    if (!settings.accept(kind)) {
      return;
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
      // Lock parent horizontal scrolling while erasing stroke
      widget.onRequestParentScrollLock?.call(true);
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
    _notifyDrawingActivity();
    _activeDrawingPointerId = details.pointer;
    // Lock parent horizontal scrolling while drawing
    widget.onRequestParentScrollLock?.call(true);
  }

  void _update(PointerMoveEvent details) {
    final kind = details.kind;

    if (kind == PointerDeviceKind.touch) {
      _activeTouchPositions[details.pointer] = details.localPosition;

      final int touchCount = _activeTouchPositions.length;
      if (touchCount >= 2) {
        // Two-finger gestures: handle two-finger-tap candidate and two-finger scroll
        if (_twoFingerTapStart != null) {
          final bool movedTooFar = !_isTwoFingerTapMovementWithinThreshold();
          final bool timedOut = !_isTwoFingerTapWithinTimeWindow();
          if (movedTooFar || timedOut) {
            _cancelTwoFingerTapCandidate();
            _setTwoFingerScrollActive(true);
          }
        } else {
          _setTwoFingerScrollActive(true);
        }

        final Offset? focal = _computeTouchFocalPoint();
        if (_isTwoFingerScrollActive &&
            focal != null &&
            _lastTwoFingerFocalPoint != null &&
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
        _lastTwoFingerFocalPoint = focal ?? _lastTwoFingerFocalPoint;
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
    _notifyDrawingActivity();
  }

  void _end(PointerUpEvent details) {
    if (details.kind == PointerDeviceKind.touch) {
      _activeTouchPositions[details.pointer] = details.localPosition;

      final bool candidateActive = _twoFingerTapStart != null;
      final bool withinMovement =
          candidateActive && _isTwoFingerTapMovementWithinThreshold();
      final bool withinTime =
          candidateActive && _isTwoFingerTapWithinTimeWindow();

      _activeTouchPositions.remove(details.pointer);
      final bool noMoreTouches = _activeTouchPositions.length < 2;

        if (candidateActive &&
          withinTime &&
          withinMovement &&
          noMoreTouches &&
          !_isTwoFingerScrollActive) {
        _triggerTwoFingerUndo();
      } else if (noMoreTouches) {
        _clearTwoFingerGestureState();
      } else {
        _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
      }
      if (noMoreTouches) {
        // nothing to reset for pinch; keep two-finger state cleared
      } else {
        // update focal point for ongoing two-finger scroll
        _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
      }
    }

    if (_activeDrawingPointerId != details.pointer) {
      return;
    }

    final tool = widget.resolveTool(_activeToolDuringStrokeId);
    _activeDrawingPointerId = null;
    _activeToolDuringStrokeId = null;

    // Unlock parent horizontal scrolling when stroke ends
    widget.onRequestParentScrollLock?.call(false);

    if (tool.isEraser) {
      if (_didEraseDuringDrag) {
        widget.onPersistDrawing();
        _handleControllerChanged();
      }
      _didEraseDuringDrag = false;
      _notifyDrawingActivity();
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
    _notifyDrawingActivity();
  }

  void _cancel(PointerCancelEvent details) {
    if (details.kind == PointerDeviceKind.touch) {
      _activeTouchPositions.remove(details.pointer);
      _resetTwoFingerScrollState();
      // pinch removed: nothing else to do
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
    _notifyDrawingActivity();
  }

  bool _applyEraserPoint(Offset position, DrawingTool tool) {
    final bool erased = widget.drawingController.eraseAt(
      position,
      radius: widget.eraserRadiusFor(tool),
    );
    if (erased) {
      _notifyDrawingActivity();
    }
    return erased;
  }

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
      onNotification: (notification) {
        final handled = _handleScrollNotification(notification);
        if (notification.metrics.axis == Axis.vertical &&
            widget.onScrollOffsetChanged != null &&
            _canvasScrollController.hasClients &&
            (notification is ScrollUpdateNotification ||
                notification is OverscrollNotification ||
                notification is UserScrollNotification)) {
          widget.onScrollOffsetChanged!(_canvasScrollController.offset);
        }
        return handled;
      },
      child: SingleChildScrollView(
        key: widget.scrollKey,
        controller: _canvasScrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          height: _canvasHeight,
          child: InteractiveViewer(
            // Zoom disabled intentionally
            panEnabled: false,
            scaleEnabled: false,
            boundaryMargin: const EdgeInsets.symmetric(
              horizontal: 120,
              vertical: 120,
            ),
            alignment: Alignment.topCenter,
            child: NotePaperBackground(
              paperStyle: widget.paperStyle,
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
                            currentStroke:
                                widget.drawingController.currentStroke,
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
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: ConvexHullsPainter(
                              hulls: _convexHulls,
                              boundingBoxes: _boundingBoxes,
                            ),
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
