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
import 'package:ai_handwriting_app/features/drawing/domain/webview_node.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/ai_lasso_panel.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/canvas_gesture_recognizer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/utils/geometry_utils.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/canvas_layers/web_view_layer.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/canvas_layers/strokes_layer.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/canvas_layers/lasso_selection_layer.dart';

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
  final Set<String> _selectedWebViewIds = <String>{};
  List<Rect> _selectedStrokeBounds = const <Rect>[];
  bool _isDraggingSelection = false;
  bool _isResizingSelection = false;
  String? _resizingWebViewId;
  Offset? _lastDragPosition;

  bool _aiPanelOpen = false;
  bool _isCapturingForAi = false;
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

  bool get _isSelectionLassoTool =>
      widget.currentTool.id == DrawingToolDefaults.selectionLassoId;

  final GlobalKey _canvasRepaintKey = GlobalKey();
  final StrokesPictureCache _pictureCache = StrokesPictureCache();

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
      if (!_isLassoTool && !_isSelectionLassoTool) {
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
    _selectedWebViewIds.clear();
    _selectedStrokeBounds = const <Rect>[];
    _aiBoundingBoxes = const <AiBoundingBox>[];
    _isDraggingSelection = false;
    _isResizingSelection = false;
    _resizingWebViewId = null;
    _lastDragPosition = null;
    if (closeAiPanel) {
      _aiPanelOpen = false;
    }
  }

  @override
  void dispose() {
    _shapeDetectionTimer?.cancel();
    widget.drawingController.removeListener(_handleControllerChanged);
    _canvasScrollController.dispose();
    _pictureCache.dispose();
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
      // ⚡ Bolt: O(Strokes) bounds calculation instead of O(Strokes * Points)
      final y = stroke.boundingBox.bottom;
      if (y > maxY) {
        maxY = y;
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

  bool _handleTouchDown(PointerDownEvent details) {
    if (details.kind != PointerDeviceKind.touch) return true;

    _gestureRecognizer.handlePointerDown(details);

    if (_gestureRecognizer.currentTouchCount >= 3) {
      _abortDrawing();
      return false;
    } else if (_gestureRecognizer.currentTouchCount == 2) {
      _abortDrawing();
      return false;
    }

    final width = context.size?.width ?? double.infinity;
    if (details.localPosition.dx < 40 ||
        details.localPosition.dx > width - 40) {
      return false;
    }
    return true;
  }

  bool _handleNavigationDown(PointerDownEvent details) {
    if (details.kind == PointerDeviceKind.mouse &&
        details.buttons == kSecondaryButton) {
      _activeNavigationPointerId = details.pointer;
      _lastNavigationPosition = details.localPosition;
      _horizontalNavigationDelta = 0;
      return true;
    }
    return false;
  }

  void _handleLassoDown(PointerDownEvent details) {
    if (_isSelectionLassoTool &&
        (_selectedStrokeIndices.isNotEmpty || _selectedWebViewIds.isNotEmpty)) {
      // First check for resize handles of selected web views
      for (final wv in widget.drawingController.webViewNodes) {
        if (_selectedWebViewIds.contains(wv.id)) {
          final resizeHandle = Rect.fromLTWH(
            wv.rect.right - 20,
            wv.rect.bottom - 20,
            30,
            30,
          );
          if (resizeHandle.inflate(10).contains(details.localPosition)) {
            _isResizingSelection = true;
            _resizingWebViewId = wv.id;
            _lastDragPosition = details.localPosition;
            _activeLassoPointerId = details.pointer;
            widget.onRequestParentScrollLock?.call(true);
            return;
          }
        }
      }

      // Then check if we tapped inside an existing selection to drag it.
      bool hitSelection = false;
      // Check bounds of selected strokes
      if (_selectedStrokeBounds.isNotEmpty) {
        Rect combined = _selectedStrokeBounds.first;
        for (var b in _selectedStrokeBounds) {
          combined = combined.expandToInclude(b);
        }
        if (combined.inflate(10).contains(details.localPosition)) {
          hitSelection = true;
        }
      }
      // Check bounds of selected webviews
      if (!hitSelection) {
        for (final wv in widget.drawingController.webViewNodes) {
          if (_selectedWebViewIds.contains(wv.id) &&
              wv.rect.contains(details.localPosition)) {
            hitSelection = true;
            break;
          }
        }
      }

      if (hitSelection) {
        _isDraggingSelection = true;
        _lastDragPosition = details.localPosition;
        _activeLassoPointerId = details.pointer;
        widget.onRequestParentScrollLock?.call(true);
        return;
      } else {
        // Clicked outside, clear selection
        _clearLassoSelection(closeAiPanel: false);
      }
    }

    _activeLassoPointerId = details.pointer;
    _lassoPoints
      ..clear()
      ..add(details.localPosition);
    _selectedStrokeIndices.clear();
    _selectedWebViewIds.clear();
    _selectedStrokeBounds = const <Rect>[];
    _aiBoundingBoxes = const <AiBoundingBox>[];
    widget.onRequestParentScrollLock?.call(true);
    setState(() {});
  }

  void _handleDrawingDown(PointerDownEvent details, DrawingTool tool) {
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
      widget.onRequestParentScrollLock?.call(true);
      return;
    }

    final newPoint = DrawingPoint(position: details.localPosition);
    _ensureCanvasHeightForPosition(newPoint.position.dy);

    widget.drawingController.startStroke(
      newPoint,
      color: tool.color,
      baseWidth: tool.baseWidth,
      isHighlighter: tool.isHighlighter,
      penType: tool.penType,
    );
    _activeDrawingPointerId = details.pointer;
    widget.onRequestParentScrollLock?.call(true);
  }

  void _start(PointerDownEvent details) {
    if (!_handleTouchDown(details)) return;
    if (_handleNavigationDown(details)) return;

    final settings = PointerSettingsScope.of(context);
    final kind = details.kind;

    if (!settings.accept(kind) ||
        (kind == PointerDeviceKind.mouse &&
            details.buttons != kPrimaryButton)) {
      return;
    }

    settings.register(kind);

    final tool = widget.currentTool;
    _activeToolDuringStrokeId = tool.id;
    _didEraseDuringDrag = false;

    if (_isLassoTool || _isSelectionLassoTool) {
      _handleLassoDown(details);
      return;
    }

    _handleDrawingDown(details, tool);
  }

  bool _handleTouchMove(PointerMoveEvent details) {
    if (details.kind != PointerDeviceKind.touch) return true;
    _gestureRecognizer.handlePointerMove(details);
    if (_gestureRecognizer.maintainsMultipleTouches) {
      return false;
    }
    return true;
  }

  bool _handleNavigationMove(PointerMoveEvent details) {
    if (_activeNavigationPointerId == details.pointer) {
      if (_lastNavigationPosition != null &&
          _canvasScrollController.hasClients) {
        final delta = details.localPosition - _lastNavigationPosition!;
        if (delta.dy != 0) {
          final target = (_canvasScrollController.offset - delta.dy).clamp(
            0.0,
            _canvasScrollController.position.maxScrollExtent,
          );
          _canvasScrollController.jumpTo(target);
        }
        _horizontalNavigationDelta += delta.dx;
      }
      _lastNavigationPosition = details.localPosition;
      return true;
    }
    return false;
  }

  void _handleLassoMove(PointerMoveEvent details) {
    if (_isResizingSelection &&
        _resizingWebViewId != null &&
        _lastDragPosition != null) {
      final delta = details.localPosition - _lastDragPosition!;
      _lastDragPosition = details.localPosition;

      final wvIndex = widget.drawingController.webViewNodes.indexWhere(
        (n) => n.id == _resizingWebViewId,
      );
      if (wvIndex != -1) {
        final wv = widget.drawingController.webViewNodes[wvIndex];
        final newWidth = math.max(100.0, wv.rect.width + delta.dx);
        final newHeight = math.max(100.0, wv.rect.height + delta.dy);
        final newRect = Rect.fromLTWH(
          wv.rect.left,
          wv.rect.top,
          newWidth,
          newHeight,
        );
        widget.drawingController.updateWebViewNodeRect(wv.id, newRect);
      }
      return;
    }

    if (_isDraggingSelection && _lastDragPosition != null) {
      final delta = details.localPosition - _lastDragPosition!;
      _lastDragPosition = details.localPosition;
      widget.drawingController.translateSelection(
        delta,
        _selectedStrokeIndices,
        _selectedWebViewIds,
      );

      _selectedStrokeBounds = _selectedStrokeBounds
          .map((r) => r.shift(delta))
          .toList();
      setState(() {});
      return;
    }

    final Offset next = details.localPosition;
    final Offset? last = _lassoPoints.isNotEmpty ? _lassoPoints.last : null;
    if (last == null || (next - last).distanceSquared > 3) {
      _lassoPoints.add(next);
      setState(() {});
    }
  }

  void _handleDrawingMove(PointerMoveEvent details) {
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

    final newPoint = DrawingPoint(position: details.localPosition);
    _ensureCanvasHeightForPosition(newPoint.position.dy);
    widget.drawingController.updateStroke(newPoint);

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

  void _update(PointerMoveEvent details) {
    if (!_handleTouchMove(details)) return;
    if (_handleNavigationMove(details)) return;

    if (_activeLassoPointerId == details.pointer && details.down) {
      _handleLassoMove(details);
      return;
    }

    if (_activeDrawingPointerId != details.pointer || !details.down) {
      return;
    }

    _handleDrawingMove(details);
  }

  bool _handleTouchUp(PointerUpEvent details) {
    if (details.kind != PointerDeviceKind.touch) return true;
    _gestureRecognizer.handlePointerUp(details);
    if (_gestureRecognizer.maintainsMultipleTouches) {
      return false;
    }
    return true;
  }

  bool _handleNavigationUp(PointerUpEvent details) {
    if (_activeNavigationPointerId == details.pointer) {
      if (_horizontalNavigationDelta.abs() > _pagingThreshold) {
        _handleRightClickPaging(_horizontalNavigationDelta < 0);
      }
      _activeNavigationPointerId = null;
      _lastNavigationPosition = null;
      _horizontalNavigationDelta = 0;
      return true;
    }
    return false;
  }

  void _handleLassoUp(PointerUpEvent details) {
    _activeLassoPointerId = null;
    widget.onRequestParentScrollLock?.call(false);

    if (_isResizingSelection) {
      _isResizingSelection = false;
      _resizingWebViewId = null;
      _lastDragPosition = null;
      widget.onPersistDrawing();
      setState(() {});
      return;
    }

    if (_isDraggingSelection) {
      _isDraggingSelection = false;
      _lastDragPosition = null;
      widget.onPersistDrawing();
      setState(() {});
      return;
    }

    final points = List<Offset>.unmodifiable(_lassoPoints);
    if (points.length >= 3) {
      final selection = CanvasGeometryUtils.selectStrokesWithinLasso(
        widget.drawingController.strokes,
        points,
      );
      _selectedStrokeIndices
        ..clear()
        ..addAll(selection.indices);
      _selectedStrokeBounds = selection.bounds;

      if (_isSelectionLassoTool) {
        final lassoBounds = CanvasGeometryUtils.boundsOfOffsets(points);
        _selectedWebViewIds.clear();
        for (final wv in widget.drawingController.webViewNodes) {
          if (lassoBounds.overlaps(wv.rect)) {
            _selectedWebViewIds.add(wv.id);
          }
        }
      }

      if (_isAiLassoTool &&
          (_selectedStrokeIndices.isNotEmpty || _lassoPoints.length >= 3)) {
        _lastAiLassoPoints
          ..clear()
          ..addAll(_lassoPoints);
        setState(() {
          _aiPanelOpen = true;
          _aiBoundingBoxes = const <AiBoundingBox>[];

          final screenWidth = MediaQuery.of(context).size.width;
          final double initialX = _lassoPoints.isNotEmpty
              ? _lassoPoints.first.dx
              : 16.0;
          final double clampedX = math.min(
            initialX,
            math.max(16.0, screenWidth - 540.0),
          );
          final double initialY = _lassoPoints.isNotEmpty
              ? _lassoPoints.first.dy
              : 16.0;

          _aiPanelPosition = Offset(clampedX, initialY);
        });
      }
    } else {
      _selectedStrokeIndices.clear();
      _selectedStrokeBounds = const <Rect>[];
    }

    _lassoPoints.clear();
    setState(() {});
  }

  void _handleDrawingUp(PointerUpEvent details) {
    final tool = widget.resolveTool(_activeToolDuringStrokeId);
    _activeDrawingPointerId = null;
    _activeToolDuringStrokeId = null;
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

  void _end(PointerUpEvent details) {
    if (!_handleTouchUp(details)) return;
    if (_handleNavigationUp(details)) return;

    if (_activeLassoPointerId == details.pointer) {
      _handleLassoUp(details);
      return;
    }

    if (_activeDrawingPointerId != details.pointer) {
      return;
    }

    _handleDrawingUp(details);
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

  Future<({ui.Image image, Rect bounds})?> _captureCanvasRegion() async {
    try {
      // Hide overlays to ensure the AI doesn't see blue highlighter boxes
      setState(() => _isCapturingForAi = true);
      // Wait for the next frame to let the UI update
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final boundary =
          _canvasRepaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isCapturingForAi = false);
        return null;
      }

      final ui.Image fullImage = await boundary.toImage(pixelRatio: 1.5);

      // Calculate bounds and add padding so the AI has context around the text
      final Rect selectionBounds = CanvasGeometryUtils.boundsOfOffsets(
        _lastAiLassoPoints,
      ).inflate(24.0);

      // Crop the image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // We need to scale the bounds by the pixelRatio
      final src = Rect.fromLTWH(
        selectionBounds.left * 1.5,
        selectionBounds.top * 1.5,
        selectionBounds.width * 1.5,
        selectionBounds.height * 1.5,
      );
      final dst = Rect.fromLTWH(
        0,
        0,
        selectionBounds.width * 1.5,
        selectionBounds.height * 1.5,
      );

      canvas.drawImageRect(fullImage, src, dst, Paint());
      final picture = recorder.endRecording();

      final int cropWidth = (selectionBounds.width * 1.5).ceil();
      final int cropHeight = (selectionBounds.height * 1.5).ceil();

      final croppedImage = await picture.toImage(cropWidth, cropHeight);

      setState(() => _isCapturingForAi = false);
      return (image: croppedImage, bounds: selectionBounds);
    } catch (e) {
      debugPrint('Error capturing canvas: $e');
      if (mounted) {
        setState(() => _isCapturingForAi = false);
      }
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

  // Erstellt ein gepuffertes Viewport-Rechteck, das sich nur alle 500 Pixel ändert,
  // um den Picture-Cache nicht bei jedem einzelnen Scroll-Frame zu invalidieren.
  Rect _getViewportRect() {
    double offset = 0.0;
    if (_canvasScrollController.hasClients) {
      offset = _canvasScrollController.offset;
    }
    final size = MediaQuery.sizeOf(context);
    final double chunkY = (offset / 500).floor() * 500.0;
    return Rect.fromLTWH(0, chunkY - 500, size.width, size.height + 1500);
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: _start,
                          onPointerMove: _update,
                          onPointerUp: _end,
                          onPointerCancel: _cancel,
                          child: Stack(
                            children: [
                              // Render WebViews
                              WebViewLayer(
                                drawingController: widget.drawingController,
                                selectedWebViewIds: _selectedWebViewIds,
                              ),
                              StrokesLayer(
                                drawingController: widget.drawingController,
                                scrollController: _canvasScrollController,
                                pictureCache: _pictureCache,
                                getViewportRect: _getViewportRect,
                              ),
                              LassoSelectionLayer(
                                lassoPoints: _lassoPoints,
                                selectedStrokeBounds:
                                    _aiPanelOpen &&
                                        _selectedStrokeBounds.isEmpty &&
                                        _lastAiLassoPoints.isNotEmpty
                                    ? <Rect>[
                                        CanvasGeometryUtils.boundsOfOffsets(
                                          _lastAiLassoPoints,
                                        ),
                                      ]
                                    : _selectedStrokeBounds,
                                aiBoundingBoxes: _aiBoundingBoxes,
                                selectionColor: scheme.primary,
                                lassoColor: scheme.primary,
                                isCapturingForAi: _isCapturingForAi,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_aiPanelOpen)
                        AiLassoPanel(
                          initialPosition: _aiPanelPosition,
                          lassoPoints: _lastAiLassoPoints,
                          onClose: () {
                            if (mounted) {
                              setState(() => _aiPanelOpen = false);
                            }
                          },
                          onAiBoxesExtracted: (List<AiBoundingBox> boxes) {
                            if (mounted) {
                              setState(() => _aiBoundingBoxes = boxes);
                            }
                          },
                          captureRegion: _captureCanvasRegion,
                          onKeepHighlights: () {
                            if (_aiBoundingBoxes.isEmpty) return;
                            final newStrokes = <Stroke>[];
                            for (final box in _aiBoundingBoxes) {
                              // Make a horizontal highlighter stroke bridging the box
                              final yCenter = box.rect.center.dy;
                              final p1 = DrawingPoint(
                                position: Offset(box.rect.left, yCenter),
                              );
                              final p2 = DrawingPoint(
                                position: Offset(box.rect.right, yCenter),
                              );
                              newStrokes.add(
                                Stroke(
                                  points: [p1, p2],
                                  color: box.color.withValues(alpha: 0.4),
                                  baseWidth: math.max(4.0, box.rect.height),
                                  isHighlighter: true,
                                  isPerfectShape: true,
                                ),
                              );
                            }
                            widget.drawingController.addStrokes(newStrokes);
                            widget.onPersistDrawing();
                            _handleControllerChanged();
                            setState(() {
                              _aiBoundingBoxes = const <AiBoundingBox>[];
                              _aiPanelOpen = false;
                            });
                          },
                          onGenerateGraph: (String htmlContent) {
                            final Rect selectionBounds =
                                CanvasGeometryUtils.boundsOfOffsets(
                                  _lastAiLassoPoints,
                                );
                            final Rect nodeRect = selectionBounds.isEmpty
                                ? Rect.fromLTWH(
                                    _aiPanelPosition.dx,
                                    _aiPanelPosition.dy + 60,
                                    400,
                                    300,
                                  )
                                : selectionBounds.inflate(24);

                            final node = WebViewNode(
                              rect: nodeRect,
                              htmlContent: htmlContent,
                            );
                            widget.drawingController.addWebViewNode(node);
                            widget.onPersistDrawing();
                            if (mounted) {
                              setState(() {
                                _aiPanelOpen = false;
                              });
                            }
                          },
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
    return scrollableCanvas;
  }
}

class _DrawingScrollBehavior extends MaterialScrollBehavior {
  const _DrawingScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.mouse,
    PointerDeviceKind.unknown,
  };
}
