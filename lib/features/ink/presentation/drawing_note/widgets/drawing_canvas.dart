import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/ai_lasso_panel.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/canvas_gesture_recognizer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Repräsentiert eine Bounding Box für KI-Ergebnisse.
class AiBoundingBox {
  /// Erstellt eine neue [AiBoundingBox].
  const AiBoundingBox(this.rect, this.color);

  /// Das Rechteck der Bounding Box.
  final Rect rect;

  /// Die Farbe der Bounding Box.
  final Color color;
}

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
    required this.onThreeFingerRedo,
    required this.paperStyle,
    this.pdfDocument,
    this.pdfPageIndex,
    this.scrollKey,
    this.initScrollOffset,
    this.onScrollOffsetChanged,
    this.onPageNavigation,
    this.initialCanvasHeight = 1600,
    this.canvasBottomPadding = 600,
    this.onRequestParentScrollLock,
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

  /// Wird ausgelöst, wenn die Drei-Finger-Tap-Geste erkannt wurde.
  final VoidCallback onThreeFingerRedo;

  /// Bestimmt den visuellen Hintergrund der Zeichenfläche.
  final NotePaperStyle paperStyle;

  /// Optionales bereits geladenes PDF-Dokument.
  final PdfDocument? pdfDocument;

  /// Optionaler Index (0-basiert) der Seite im PDF.
  final int? pdfPageIndex;

  /// Optionaler Key (z. B. PageStorageKey), um die Scrollposition zu speichern.
  final Key? scrollKey;

  /// Optionaler initialer Scroll-Offset, der beim ersten Build gesetzt wird.
  final double? initScrollOffset;

  /// Optionaler Callback, der bei Scroll-Änderungen den aktuellen Offset liefert.
  final ValueChanged<double>? onScrollOffsetChanged;

  /// Optionaler Callback zum Wechseln der Seite (true = nächste, false = vorherige).
  final ValueChanged<bool>? onPageNavigation;

  /// Mindesthöhe der Zeichenfläche.
  final double initialCanvasHeight;

  /// Zusätzlicher Puffer am unteren Rand.
  final double canvasBottomPadding;

  /// Optionaler Callback: true = Parent soll horizontales Scrollen sperren.
  /// Wird aufgerufen mit `true` wenn eine Zeichenaktion startet und mit `false`
  /// wenn sie endet oder abgebrochen wird.
  final ValueChanged<bool>? onRequestParentScrollLock;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late final ScrollController _canvasScrollController;
  late double _canvasHeight;
  double? _desiredInitialOffset;
  double _lastScrollExpansionTrigger = -1;
  late final CanvasGestureRecognizer _gestureRecognizer;
  Timer? _shapeDetectionTimer;

  int? _activeDrawingPointerId;
  String? _activeToolDuringStrokeId;
  bool _didEraseDuringDrag = false;
  int _lastObservedVersion = 0;

  int? _activeLassoPointerId;
  final List<Offset> _lassoPoints = <Offset>[];
  final List<Offset> _lastAiLassoPoints = <Offset>[];
  final Set<int> _selectedStrokeIndices = <int>{};
  List<Rect> _selectedStrokeBounds = const <Rect>[];
  bool _aiPanelOpen = false;
  Offset _aiPanelPosition = const Offset(16, 16);
  List<AiBoundingBox> _aiBoundingBoxes = const <AiBoundingBox>[];

  // Right-click navigation state
  int? _activeNavigationPointerId;
  Offset? _lastNavigationPosition;
  double _horizontalNavigationDelta = 0;
  static const double _pagingThreshold = 150.0;

  bool get _isLassoTool =>
      widget.currentTool.id == DrawingToolDefaults.aiLassoId;

  bool get _isAiLassoTool =>
      widget.currentTool.id == DrawingToolDefaults.aiLassoId;

  final GlobalKey _canvasRepaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _gestureRecognizer = CanvasGestureRecognizer(
      onTwoFingerUndo: _triggerTwoFingerUndo,
      onThreeFingerRedo: _triggerThreeFingerRedo,
      onTwoFingerScrollUpdate: _handleTwoFingerScrollUpdate,
    );
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
        final double target = widget.initScrollOffset!.clamp(
          0.0,
          _canvasScrollController.position.maxScrollExtent,
        );
        _canvasScrollController.jumpTo(target);
      });
    }
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
      if (!_isLassoTool) {
        _clearLassoSelection(closeAiPanel: true);
      }
      setState(() {});
    }
  }

  void _clearLassoSelection({required bool closeAiPanel}) {
    _activeLassoPointerId = null;
    _lassoPoints.clear();
    _lastAiLassoPoints.clear();
    _selectedStrokeIndices.clear();
    _selectedStrokeBounds = const <Rect>[];
    _aiBoundingBoxes = const <AiBoundingBox>[];
    if (closeAiPanel) {
      _aiPanelOpen = false;
    }
  }

  @override
  void dispose() {
    _shapeDetectionTimer?.cancel();
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
          final double target = _desiredInitialOffset!.clamp(
            0.0,
            _canvasScrollController.position.maxScrollExtent,
          );
          if ((_canvasScrollController.offset - target).abs() > 1) {
            _canvasScrollController.jumpTo(target);
          }
        });
      }
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

  void _handleTwoFingerScrollUpdate(double delta) {
    if (_canvasScrollController.hasClients) {
      final double currentOffset = _canvasScrollController.offset;
      final double maxOffset = _canvasScrollController.position.maxScrollExtent;
      final double targetOffset = (currentOffset - delta).clamp(0.0, maxOffset);
      if ((targetOffset - currentOffset).abs() > 0.01) {
        _canvasScrollController.jumpTo(targetOffset);
      }
    }
  }

  void _triggerTwoFingerUndo() {
    Feedback.forTap(context);
    widget.onTwoFingerUndo();
  }

  void _triggerThreeFingerRedo() {
    Feedback.forTap(context);
    widget.onThreeFingerRedo();
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
    _shapeDetectionTimer?.cancel();
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
        final double target = widget.initScrollOffset!.clamp(
          0.0,
          _canvasScrollController.position.maxScrollExtent,
        );
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
      _gestureRecognizer.handlePointerDown(details);

      if (_gestureRecognizer.currentTouchCount >= 3) {
        _abortDrawing();
        touchAllowsDrawing = false;
      } else if (_gestureRecognizer.currentTouchCount == 2) {
        _abortDrawing();
        touchAllowsDrawing = false;
      }

      if (!touchAllowsDrawing) {
        return;
      }
    }

    // Handle Right-Click (Secondary Button) for navigation
    if (kind == PointerDeviceKind.mouse &&
        details.buttons == kSecondaryButton) {
      _activeNavigationPointerId = details.pointer;
      _lastNavigationPosition = details.localPosition;
      _horizontalNavigationDelta = 0;
      return;
    }

    if (!settings.accept(kind) ||
        (kind == PointerDeviceKind.mouse &&
            details.buttons != kPrimaryButton)) {
      return;
    }

    settings.register(kind);

    final tool = widget.currentTool;
    _activeToolDuringStrokeId = tool.id;
    _didEraseDuringDrag = false;

    if (_isLassoTool) {
      _activeLassoPointerId = details.pointer;
      _lassoPoints
        ..clear()
        ..add(details.localPosition);
      _selectedStrokeIndices.clear();
      _selectedStrokeBounds = const <Rect>[];
      _aiBoundingBoxes = const <AiBoundingBox>[];
      widget.onRequestParentScrollLock?.call(true);
      setState(() {});
      return;
    }

    // Close AI panel when starting to draw
    if (_aiPanelOpen) {
      setState(() {
        _aiPanelOpen = false;
      });
    }

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
    _activeDrawingPointerId = details.pointer;
    // Lock parent horizontal scrolling while drawing
    widget.onRequestParentScrollLock?.call(true);
  }

  void _update(PointerMoveEvent details) {
    final kind = details.kind;

    if (kind == PointerDeviceKind.touch) {
      if (_gestureRecognizer.maintainsMultipleTouches) {
        return;
      }
    }

    // Handle Right-Click navigation
    if (_activeNavigationPointerId == details.pointer) {
      if (_lastNavigationPosition != null &&
          _canvasScrollController.hasClients) {
        final delta = details.localPosition - _lastNavigationPosition!;

        // Vertical scrolling
        if (delta.dy != 0) {
          final target = (_canvasScrollController.offset - delta.dy).clamp(
            0.0,
            _canvasScrollController.position.maxScrollExtent,
          );
          _canvasScrollController.jumpTo(target);
        }

        // Horizontal paging accumulation
        _horizontalNavigationDelta += delta.dx;
      }
      _lastNavigationPosition = details.localPosition;
      return;
    }

    if (_activeLassoPointerId == details.pointer && details.down) {
      final Offset next = details.localPosition;
      final Offset? last = _lassoPoints.isNotEmpty ? _lassoPoints.last : null;
      if (last == null || (next - last).distanceSquared > 3) {
        _lassoPoints.add(next);
        setState(() {});
      }
      return;
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

    // Shape Detection: Restart timer on significant movement
    final double dist = (details.delta).distanceSquared;
    if (dist > 1.0) {
      _shapeDetectionTimer?.cancel();
      _shapeDetectionTimer = Timer(const Duration(milliseconds: 600), () {
        if (_activeDrawingPointerId == details.pointer) {
          final snapped = widget.drawingController.trySnapToShape();
          if (snapped) {
            Feedback.forTap(context);
          }
        }
      });
    }
  }

  void _end(PointerUpEvent details) {
    if (details.kind == PointerDeviceKind.touch) {
      if (_gestureRecognizer.maintainsMultipleTouches) {
        return;
      }
    }

    // Handle Right-Click navigation end
    if (_activeNavigationPointerId == details.pointer) {
      if (_horizontalNavigationDelta.abs() > _pagingThreshold) {
        if (_horizontalNavigationDelta > 0) {
          // Swipe Right -> Previous Page
          if (widget.pdfPageIndex != null && widget.pdfPageIndex! > 0) {
            // We don't have direct access to page switching here, but we can call widget.onPageChanged
            // or similar if provided. Looking at DrawingNotePage, it uses a PageController.
            // DrawingCanvas has onPageChanged in DrawingNotePage but not directly in DrawingCanvas.
            // Wait, DrawingCanvas is wrapped in NotePageContent which has onPageChanged.
            // BUT DrawingCanvas doesn't have it.
          }
          // Let's use a generic way or add the callback.
          _handleRightClickPaging(_horizontalNavigationDelta > 0);
        } else {
          // Swipe Left -> Next Page
          _handleRightClickPaging(_horizontalNavigationDelta > 0);
        }
      }
      _activeNavigationPointerId = null;
      _lastNavigationPosition = null;
      _horizontalNavigationDelta = 0;
      return;
    }

    if (_activeLassoPointerId == details.pointer) {
      _activeLassoPointerId = null;
      widget.onRequestParentScrollLock?.call(false);

      final points = List<Offset>.unmodifiable(_lassoPoints);
      if (points.length >= 3) {
        final selection = _selectStrokesWithinLasso(
          widget.drawingController.strokes,
          points,
        );
        _selectedStrokeIndices
          ..clear()
          ..addAll(selection.indices);
        _selectedStrokeBounds = selection.bounds;

        if (_isAiLassoTool &&
            (_selectedStrokeIndices.isNotEmpty || _lassoPoints.length >= 3)) {
          _lastAiLassoPoints
            ..clear()
            ..addAll(_lassoPoints);
          setState(() {
            _aiPanelOpen = true;
            _aiBoundingBoxes = const <AiBoundingBox>[];
            _aiPanelPosition = _lassoPoints.isNotEmpty
                ? _lassoPoints.first
                : const Offset(16, 16);
          });
        }
      } else {
        _selectedStrokeIndices.clear();
        _selectedStrokeBounds = const <Rect>[];
      }

      // Clear lasso points so the drawn circle disappears
      _lassoPoints.clear();

      setState(() {});
      return;
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
      return;
    }

    _didEraseDuringDrag = false;
    _shapeDetectionTimer?.cancel();

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
      _gestureRecognizer.handlePointerCancel(details);
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
      _shapeDetectionTimer?.cancel();
    }

    if (_activeLassoPointerId == details.pointer) {
      setState(() {});
    }

    if (_activeNavigationPointerId == details.pointer) {
      _activeNavigationPointerId = null;
      _lastNavigationPosition = null;
      _horizontalNavigationDelta = 0;
    }
  }

  void _handleRightClickPaging(bool isNext) {
    widget.onPageNavigation?.call(isNext);
  }

  ({Set<int> indices, List<Rect> bounds}) _selectStrokesWithinLasso(
    List<Stroke> strokes,
    List<Offset> lassoPoints,
  ) {
    final Rect lassoBounds = _boundsOfOffsets(lassoPoints);

    final Set<int> selected = <int>{};
    final List<Rect> selectedBounds = <Rect>[];

    for (var i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      if (stroke.points.isEmpty) continue;

      final Rect strokeBounds = _boundsOfStroke(stroke);
      if (!lassoBounds.overlaps(strokeBounds)) continue;

      var hit = false;
      for (final point in stroke.points) {
        if (_isPointInPolygon(point.position, lassoPoints)) {
          hit = true;
          break;
        }
      }
      if (!hit) continue;

      selected.add(i);
      selectedBounds.add(strokeBounds);
    }

    return (indices: selected, bounds: selectedBounds);
  }

  Rect _boundsOfOffsets(List<Offset> points) {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy > maxY) maxY = p.dy;
    }
    if (!minX.isFinite || !minY.isFinite || !maxX.isFinite || !maxY.isFinite) {
      return Rect.zero;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Rect _boundsOfStroke(Stroke stroke) {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    for (final p in stroke.points) {
      final o = p.position;
      if (o.dx < minX) minX = o.dx;
      if (o.dy < minY) minY = o.dy;
      if (o.dx > maxX) maxX = o.dx;
      if (o.dy > maxY) maxY = o.dy;
    }
    if (!minX.isFinite || !minY.isFinite || !maxX.isFinite || !maxY.isFinite) {
      return Rect.zero;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].dx;
      final yi = polygon[i].dy;
      final xj = polygon[j].dx;
      final yj = polygon[j].dy;
      final bool intersect =
          ((yi > point.dy) != (yj > point.dy)) &&
          (point.dx <
              (xj - xi) *
                      (point.dy - yi) /
                      ((yj - yi) == 0 ? 1e-9 : (yj - yi)) +
                  xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  Future<ui.Image?> _captureCanvasRegion() async {
    try {
      final boundary =
          _canvasRepaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image fullImage = await boundary.toImage(pixelRatio: 2.0);
      final Rect selectionBounds = _boundsOfOffsets(_lastAiLassoPoints);

      // Crop the image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // We need to scale the bounds by the pixelRatio
      final src = Rect.fromLTWH(
        selectionBounds.left * 2.0,
        selectionBounds.top * 2.0,
        selectionBounds.width * 2.0,
        selectionBounds.height * 2.0,
      );
      final dst = Rect.fromLTWH(
        0,
        0,
        selectionBounds.width * 2.0,
        selectionBounds.height * 2.0,
      );

      canvas.drawImageRect(fullImage, src, dst, Paint());
      final picture = recorder.endRecording();

      final croppedImage = await picture.toImage(
        (selectionBounds.width * 2.0).toInt(),
        (selectionBounds.height * 2.0).toInt(),
      );

      return croppedImage;
    } catch (e) {
      debugPrint('Error capturing canvas: $e');
      return null;
    }
  }

  bool _applyEraserPoint(Offset position, DrawingTool tool) {
    final bool erased = widget.drawingController.eraseAt(
      position,
      radius: widget.eraserRadiusFor(tool),
    );
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

  bool _onScrollNotification(ScrollNotification notification) {
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
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final Widget scrollableCanvas = ScrollConfiguration(
      behavior: const _DrawingScrollBehavior(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onScrollNotification(notification),
        child: SingleChildScrollView(
          key: widget.scrollKey,
          controller: _canvasScrollController,
          physics: _activeDrawingPointerId != null
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
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
              child: RepaintBoundary(
                key: _canvasRepaintKey,
                child: NotePaperBackground(
                  paperStyle: widget.paperStyle,
                  pdfDocument: widget.pdfDocument,
                  pdfPageIndex: widget.pdfPageIndex,
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
                                version:
                                    widget.drawingController.strokesVersion,
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
                          RepaintBoundary(
                            child: CustomPaint(
                              painter: _LassoSelectionPainter(
                                lassoPoints: _lassoPoints,
                                selectedStrokeBounds:
                                    _aiPanelOpen &&
                                        _selectedStrokeBounds.isEmpty &&
                                        _lastAiLassoPoints.isNotEmpty
                                    ? <Rect>[
                                        _boundsOfOffsets(_lastAiLassoPoints),
                                      ]
                                    : _selectedStrokeBounds,
                                aiBoundingBoxes: _aiBoundingBoxes,
                                selectionColor: scheme.primary,
                                lassoColor: scheme.primary,
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
      ),
    );
    return Stack(
      children: [
        scrollableCanvas,
        if (_aiPanelOpen)
          AiLassoPanel(
            initialPosition: _aiPanelPosition,
            lassoPoints: _lastAiLassoPoints,
            onClose: () => setState(() => _aiPanelOpen = false),
            onAiBoxesExtracted: (List<AiBoundingBox> boxes) =>
                setState(() => _aiBoundingBoxes = boxes),
            captureRegion: _captureCanvasRegion,
          ),
      ],
    );
  }
}

class _LassoSelectionPainter extends CustomPainter {
  _LassoSelectionPainter({
    required List<Offset> lassoPoints,
    required List<Rect> selectedStrokeBounds,
    required List<AiBoundingBox> aiBoundingBoxes,
    required this.selectionColor,
    required this.lassoColor,
  }) : lassoPoints = List<Offset>.unmodifiable(lassoPoints),
       selectedStrokeBounds = List<Rect>.unmodifiable(selectedStrokeBounds),
       aiBoundingBoxes = List<AiBoundingBox>.unmodifiable(aiBoundingBoxes);

  final List<Offset> lassoPoints;
  final List<Rect> selectedStrokeBounds;
  final List<AiBoundingBox> aiBoundingBoxes;
  final Color selectionColor;
  final Color lassoColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedStrokeBounds.isNotEmpty) {
      final paint = Paint()
        ..color = selectionColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      double minX = double.infinity;
      double minY = double.infinity;
      double maxX = double.negativeInfinity;
      double maxY = double.negativeInfinity;

      for (final rect in selectedStrokeBounds) {
        if (rect.left < minX) minX = rect.left;
        if (rect.top < minY) minY = rect.top;
        if (rect.right > maxX) maxX = rect.right;
        if (rect.bottom > maxY) maxY = rect.bottom;
      }

      if (minX != double.infinity) {
        final combinedRect = Rect.fromLTRB(minX, minY, maxX, maxY);
        final rrect = RRect.fromRectAndRadius(
          combinedRect.inflate(6),
          const Radius.circular(10),
        );
        canvas.drawRRect(rrect, paint);
      }
    }

    if (aiBoundingBoxes.isNotEmpty) {
      for (final aiBox in aiBoundingBoxes) {
        final paint = Paint()
          ..color = aiBox.color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        final rrect = RRect.fromRectAndRadius(
          aiBox.rect.inflate(4),
          const Radius.circular(8),
        );
        canvas.drawRRect(rrect, paint);
      }
    }

    if (lassoPoints.length >= 2) {
      final paint = Paint()
        ..color = lassoColor.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final path = Path()..moveTo(lassoPoints.first.dx, lassoPoints.first.dy);
      for (final p in lassoPoints.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LassoSelectionPainter oldDelegate) =>
      oldDelegate.lassoPoints != lassoPoints ||
      oldDelegate.selectedStrokeBounds != selectedStrokeBounds ||
      oldDelegate.aiBoundingBoxes != aiBoundingBoxes ||
      oldDelegate.selectionColor != selectionColor ||
      oldDelegate.lassoColor != lassoColor;
}

class _DrawingScrollBehavior extends MaterialScrollBehavior {
  const _DrawingScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.mouse,
    PointerDeviceKind.unknown,
  };
}
