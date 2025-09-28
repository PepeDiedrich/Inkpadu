import 'dart:math' as math;

import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/drawing/application/stroke_simplifier_async.dart'
    as async_simpl;
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';

/// Verwaltet den Zustand der Zeichenfläche und stellt Undo/Redo-Funktionen bereit.
class DrawingController extends ChangeNotifier {
  /// Aktuell gezeichnete Striche.
  List<Stroke> _strokes = const [];

  /// Version der Strichliste. Erhöht sich bei jeder strukturellen Änderung
  /// (Undo, Redo, Clear, Abschluss eines Strichs). Dient für shouldRepaint.
  int _strokesVersion = 0;

  /// Der temporäre Strich, der gerade entsteht.
  Stroke? _currentStroke;

  /// Stack für Wiederherstellen-Operationen.
  final List<Stroke> _redoStack = [];

  /// Liefert eine unveränderliche Sicht auf alle gespeicherten Striche.
  List<Stroke> get strokes => List.unmodifiable(_strokes);

  /// Liefert die aktuelle Versionsnummer der Strichliste.
  int get strokesVersion => _strokesVersion;

  /// Gibt den aktuell entstehenden Strich zurück.
  Stroke? get currentStroke => _currentStroke;

  /// `true`, wenn mindestens ein Strich rückgängig gemacht werden kann.
  bool get canUndo => _strokes.isNotEmpty;

  /// `true`, wenn ein rückgängig gemachter Strich wiederhergestellt werden kann.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Übernimmt eine bestehende Liste von Strichen in den Controller.
  void initialize(List<Stroke> initialStrokes) {
    _strokes = List<Stroke>.of(initialStrokes);
    _strokesVersion++; // Initialisierung zählt als Änderung.
    _currentStroke = null;
    _redoStack.clear();
    notifyListeners();
  }

  /// Startet einen neuen Strich mit dem übergebenen [point].
  void startStroke(
    DrawingPoint point, {
    required Color color,
    required double baseWidth,
    bool isHighlighter = false,
  }) {
    _currentStroke = Stroke(
      points: [point],
      color: color,
      baseWidth: baseWidth,
      isHighlighter: isHighlighter,
    );
    _redoStack.clear();
    notifyListeners();
  }

  /// Fügt dem aktuellen Strich einen weiteren Punkt hinzu.
  void updateStroke(DrawingPoint point) {
    if (_currentStroke == null) return;
    _currentStroke = _currentStroke!.copyWith(
      points: List<DrawingPoint>.of(_currentStroke!.points)..add(point),
    );
    notifyListeners();
  }

  /// Beendet den aktuellen Strich und speichert ihn dauerhaft.
  /// Gibt `true` zurück, wenn der Strich übernommen wurde.
  Future<bool> endStroke({bool simplify = true}) async {
    if (_currentStroke == null) {
      return false;
    }

    final stroke = _currentStroke!;
    _currentStroke = null;

    if (stroke.points.length < 2) {
      notifyListeners();
      return false;
    }

    Stroke strokeToStore = stroke;

    if (simplify) {
      final Stroke simplified = await async_simpl.simplifyStrokeAsync(
        stroke,
        tolerance: _simplificationToleranceFor(stroke),
      );

      if (simplified.points.length < 2) {
        notifyListeners();
        return false;
      }
      strokeToStore = simplified;
    }

    _strokes = List<Stroke>.of(_strokes)..add(strokeToStore);
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Macht den zuletzt gespeicherten Strich rückgängig.
  bool undo() {
    if (_strokes.isEmpty) return false;

    final updated = List<Stroke>.of(_strokes);
    final removed = updated.removeLast();
    _redoStack.add(removed);
    _strokes = updated;
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Stellt den zuletzt rückgängig gemachten Strich wieder her.
  bool redo() {
    if (_redoStack.isEmpty) return false;

    final stroke = _redoStack.removeLast();
    _strokes = List<Stroke>.of(_strokes)..add(stroke);
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Entfernt alle Striche und setzt den Controller zurück.
  bool clear() {
    if (_strokes.isEmpty && _currentStroke == null) {
      return false;
    }
    _strokes = const [];
    _currentStroke = null;
    _redoStack.clear();
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Bricht den aktuell entstehenden Strich ab, ohne ihn zu speichern.
  void cancelCurrentStroke() {
    if (_currentStroke == null) return;
    _currentStroke = null;
    notifyListeners();
  }

  double _simplificationToleranceFor(Stroke stroke) {
    final effective = stroke.baseWidth * 0.2;
    const minTolerance = 0.3;
    return effective < minTolerance ? minTolerance : effective;
  }

  // Forwarder für vereinfachte Testbarkeit / Analyzer Workaround.
  // Intentionally empty: keine zusätzliche Forwarding-Methode notwendig.
}

/// Seite zum Bearbeiten / Zeichnen einer einzelnen handschriftlichen Notiz.
class DrawingNotePage extends StatefulWidget {
  /// Erstellt eine Seite für die Notiz mit der gegebenen [noteId].
  const DrawingNotePage({super.key, required this.noteId});

  /// ID der zu bearbeitenden Notiz.
  final String noteId;

  @override
  State<DrawingNotePage> createState() => _DrawingNotePageState();
}

class _DrawingNotePageState extends State<DrawingNotePage> {
  late InkNote _note;
  late InkNotesController _inkNotesController;
  final DrawingController _drawingController = DrawingController();
  static const double _minSidebarFraction = 0.0;
  static const double _minVisibleSidebarFraction = 0.15;
  static const double _maxSidebarFraction = 0.45;
  static const double _dragHandleWidth = 12;
  static const Duration _panelAnimationDuration = Duration(milliseconds: 220);
  static const Curve _panelAnimationCurve = Curves.easeOutCubic;
  double _sidebarFraction = 0.3;
  double? _previewSidebarFraction;
  bool _isResizing = false;
  _ResizeTrend _resizeTrend = _ResizeTrend.none;
  static const double _initialCanvasHeight = 1600;
  static const double _canvasBottomPadding = 600;
  late final ScrollController _canvasScrollController;
  double _canvasHeight = _initialCanvasHeight;
  double _lastScrollExpansionTrigger = -1;
  final Map<int, Offset> _activeTouchPositions = <int, Offset>{};
  bool _isTwoFingerScrollActive = false;
  Offset? _lastTwoFingerFocalPoint;
  int? _activeDrawingPointerId;

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
    return math.max(_initialCanvasHeight, maxY + _canvasBottomPadding);
  }

  void _ensureCanvasHeightForPosition(double yPosition) {
    final requiredHeight = math.max(
      _initialCanvasHeight,
      yPosition + _canvasBottomPadding,
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
    if (_activeDrawingPointerId != null) {
      _drawingController.cancelCurrentStroke();
      _activeDrawingPointerId = null;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final metrics = notification.metrics;
    if (metrics.extentAfter > _canvasBottomPadding * 0.5) {
      return false;
    }
    if (metrics.pixels <= _lastScrollExpansionTrigger + 1) {
      return false;
    }

    final double visibleExtent =
        metrics.pixels + metrics.viewportDimension + _canvasBottomPadding;
    if (visibleExtent <= _canvasHeight) {
      return false;
    }

    _lastScrollExpansionTrigger = metrics.pixels;
    setState(() {
      _canvasHeight = math.max(_canvasHeight, visibleExtent);
    });
    return false;
  }

  @override
  void initState() {
    super.initState();
    _canvasScrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _inkNotesController = InkNotesScope.of(context);
    final idx = _inkNotesController.notes.indexWhere(
      (n) => n.id == widget.noteId,
    );
    if (idx == -1) {
      debugPrint(
        'Warnung: Notiz mit ID ${widget.noteId} nicht gefunden. Erzeuge Platzhalter.',
      );
      final placeholder = InkNote(
        id: widget.noteId,
        title: 'Fehlende Notiz',
        updatedAt: DateTime.now(),
        page: NotePage(strokes: const []),
      );
      _inkNotesController.upsert(placeholder);
      _note = placeholder;
    } else {
      _note = _inkNotesController.notes[idx];
    }
    _activeTouchPositions.clear();
    _isTwoFingerScrollActive = false;
    _lastTwoFingerFocalPoint = null;
    _activeDrawingPointerId = null;
    _lastScrollExpansionTrigger = -1;
    _canvasHeight = _requiredCanvasHeightForStrokes(_note.page.strokes);
    _drawingController.initialize(_note.page.strokes);
  }

  @override
  void dispose() {
    _drawingController.dispose();
    _canvasScrollController.dispose();
    super.dispose();
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

    final newPoint = DrawingPoint(
      position: details.localPosition,
      pressure: details.pressure,
    );

    _ensureCanvasHeightForPosition(newPoint.position.dy);

    _drawingController.startStroke(
      newPoint,
      color: Colors.amber,
      baseWidth: 6.0,
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

    if (_activeDrawingPointerId != details.pointer ||
        _drawingController.currentStroke == null ||
        !details.down) {
      return;
    }

    final newPoint = DrawingPoint(
      position: details.localPosition,
      pressure: details.pressure,
    );

    _ensureCanvasHeightForPosition(newPoint.position.dy);

    _drawingController.updateStroke(newPoint);
  }

  void _end(PointerUpEvent details) {
    if (details.kind == PointerDeviceKind.touch) {
      _activeTouchPositions.remove(details.pointer);
      _resetTwoFingerScrollState();
    }

    if (_activeDrawingPointerId != details.pointer) {
      return;
    }

    _activeDrawingPointerId = null;
    final bool simplify = EditorSettingsScope.of(context).lineSimplifierEnabled;
    _drawingController.endStroke(simplify: simplify).then((accepted) {
      if (accepted) {
        _persistDrawing();
      }
    });
  }

  void _cancel(PointerCancelEvent details) {
    if (details.kind == PointerDeviceKind.touch) {
      _activeTouchPositions.remove(details.pointer);
      _resetTwoFingerScrollState();
    }

    if (_activeDrawingPointerId == details.pointer) {
      _drawingController.cancelCurrentStroke();
      _activeDrawingPointerId = null;
    }
  }

  void _handleUndo() {
    if (_drawingController.undo()) {
      _persistDrawing();
    }
  }

  void _handleRedo() {
    if (_drawingController.redo()) {
      _persistDrawing();
    }
  }

  void _handleClear() {
    if (_drawingController.clear()) {
      _persistDrawing();
    }
  }

  void _persistDrawing() {
    final updatedPage = _note.page.copyWith(
      strokes: _drawingController.strokes,
    );

    final updatedNote = _note.copyWith(
      page: updatedPage,
      updatedAt: DateTime.now(),
    );

    _inkNotesController.upsert(updatedNote);

    if (mounted) {
      setState(() {
        _note = updatedNote;
        _canvasHeight = math.max(
          _canvasHeight,
          _requiredCanvasHeightForStrokes(updatedPage.strokes),
        );
      });
    }
  }

  double _snapSidebarFraction(
    double previousFraction,
    double proposedFraction,
  ) {
    final double clamped = proposedFraction
        .clamp(_minSidebarFraction, _maxSidebarFraction)
        .toDouble();
    if (clamped < _minVisibleSidebarFraction) {
      if (clamped < previousFraction) {
        return _minSidebarFraction;
      }
      if (clamped > previousFraction) {
        return _minVisibleSidebarFraction;
      }
    }
    return clamped;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: Text(_note.title),
      actions: [
        AnimatedBuilder(
          animation: _drawingController,
          builder: (context, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _drawingController.canUndo ? _handleUndo : null,
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
              ),
              IconButton(
                onPressed: _drawingController.canRedo ? _handleRedo : null,
                icon: const Icon(Icons.redo),
                tooltip: 'Redo',
              ),
              IconButton(
                onPressed: _drawingController.canUndo ? _handleClear : null,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final editorSettings = EditorSettingsScope.of(context);
        final panelSide = editorSettings.sidebarSide;
        final bool panelOnRight = editorSettings.isPanelOnRight;

        final double maxWidth = constraints.maxWidth;
        final double baseWidth = maxWidth <= 0 ? 1 : maxWidth;
        final double sidebarFraction = _sidebarFraction
            .clamp(_minSidebarFraction, _maxSidebarFraction)
            .toDouble();
        final double previewFraction =
            (_previewSidebarFraction ?? sidebarFraction)
                .clamp(_minSidebarFraction, _maxSidebarFraction)
                .toDouble();
        final double panelWidth = baseWidth * sidebarFraction;
        final double handlePreviewWidth = baseWidth * previewFraction;
        final bool isCollapsed = sidebarFraction < _minVisibleSidebarFraction;
        final Widget canvas = ScrollConfiguration(
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
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.15),
                  ),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: _start,
                    onPointerMove: _update,
                    onPointerUp: _end,
                    onPointerCancel: _cancel,
                    child: AnimatedBuilder(
                      animation: _drawingController,
                      builder: (context, child) => Stack(
                        children: [
                          RepaintBoundary(
                            child: CustomPaint(
                              painter: FinishedStrokesPainter(
                                strokes: _drawingController.strokes,
                                version: _drawingController.strokesVersion,
                              ),
                            ),
                          ),
                          RepaintBoundary(
                            child: CustomPaint(
                              painter: CurrentStrokePainter(
                                currentStroke: _drawingController.currentStroke,
                                pointCount:
                                    _drawingController
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

        final double rawHandleOffset = math.max(
          handlePreviewWidth - _dragHandleWidth,
          0,
        );
        final double handleOffset = rawHandleOffset > baseWidth
            ? baseWidth
            : rawHandleOffset;
        final double orientationFactor = panelOnRight ? 1 : -1;

        return Stack(
          children: [
            Positioned.fill(child: canvas),
            AnimatedPositioned(
              duration: _panelAnimationDuration,
              curve: _panelAnimationCurve,
              top: 0,
              bottom: 0,
              left: panelOnRight ? null : 0,
              right: panelOnRight ? 0 : null,
              width: panelWidth,
              child: IgnorePointer(
                ignoring: isCollapsed,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: isCollapsed ? 0 : 1,
                  child: _AssistantPanel(
                    isActive: _isResizing,
                    widthFraction: previewFraction,
                    resizeTrend: _resizeTrend,
                    side: panelSide,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: panelOnRight ? null : handleOffset,
              right: panelOnRight ? handleOffset : null,
              child: SizedBox(
                width: _dragHandleWidth,
                child: _SidebarResizeHandle(
                  isActive: _isResizing,
                  side: panelSide,
                  onDragStart: () => setState(() {
                    _isResizing = true;
                    _previewSidebarFraction = _sidebarFraction;
                    _resizeTrend = _ResizeTrend.none;
                  }),
                  onDragUpdate: (delta) {
                    setState(() {
                      final double currentPreview =
                          _previewSidebarFraction ?? _sidebarFraction;
                      final double deltaFraction =
                          (delta / baseWidth) * orientationFactor;
                      final double proposedFraction =
                          currentPreview - deltaFraction;
                      final double nextPreview = _snapSidebarFraction(
                        currentPreview,
                        proposedFraction,
                      );

                      _previewSidebarFraction = nextPreview;

                      if (nextPreview > currentPreview) {
                        _resizeTrend = _ResizeTrend.expand;
                      } else if (nextPreview < currentPreview) {
                        _resizeTrend = _ResizeTrend.shrink;
                      } else {
                        _resizeTrend = _ResizeTrend.none;
                      }
                    });
                  },
                  onDragEnd: () => setState(() {
                    final double previous = _sidebarFraction;
                    final double target =
                        _previewSidebarFraction ?? _sidebarFraction;
                    final double adjustedTarget = _snapSidebarFraction(
                      previous,
                      target,
                    );

                    _sidebarFraction = adjustedTarget;
                    _previewSidebarFraction = null;
                    _isResizing = false;
                    _resizeTrend = _ResizeTrend.none;
                  }),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _AssistantPanel extends StatelessWidget {
  const _AssistantPanel({
    required this.isActive,
    required this.widthFraction,
    required this.resizeTrend,
    required this.side,
  });

  final bool isActive;
  final double widthFraction;
  final _ResizeTrend resizeTrend;
  final EditorSidebarSide side;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool panelOnRight = side == EditorSidebarSide.right;
    final Color borderColor = isActive
        ? AppColors.primaryAccent
        : colorScheme.outlineVariant;
    final BorderSide highlightedBorder = BorderSide(
      color: borderColor,
      width: 2,
    );
    final BorderRadius borderRadius = BorderRadius.horizontal(
      left: panelOnRight ? const Radius.circular(20) : Radius.zero,
      right: panelOnRight ? Radius.zero : const Radius.circular(20),
    );

    final int percentage = (widthFraction * 100).round();
    final Color headerBadgeColor = colorScheme.primaryContainer;
    final Color cardBackground = colorScheme.surfaceContainerHigh;
    final Color indicatorBackground = colorScheme.inverseSurface;
    final Color indicatorTextColor = colorScheme.onInverseSurface;

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: borderRadius,
            border: Border(
              left: panelOnRight ? highlightedBorder : BorderSide.none,
              right: panelOnRight ? BorderSide.none : highlightedBorder,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: headerBadgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'KI-Assistent',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Hier erscheinen später KI-Antworten zu deiner Notiz.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.flash_on_outlined),
                  label: const Text('Wird bald aktiviert'),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: panelOnRight ? 16 : null,
          left: panelOnRight ? null : 16,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: isActive ? 1 : 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: indicatorBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _trendIcon(panelOnRight, resizeTrend),
                      color: AppColors.primaryAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$percentage %',
                      style: textTheme.labelMedium?.copyWith(
                        color: indicatorTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _trendIcon(bool panelOnRight, _ResizeTrend trend) {
    if (trend == _ResizeTrend.expand) {
      return panelOnRight
          ? Icons.keyboard_double_arrow_left
          : Icons.keyboard_double_arrow_right;
    }
    if (trend == _ResizeTrend.shrink) {
      return panelOnRight
          ? Icons.keyboard_double_arrow_right
          : Icons.keyboard_double_arrow_left;
    }
    return Icons.open_with;
  }
}

class _SidebarResizeHandle extends StatelessWidget {
  const _SidebarResizeHandle({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.isActive,
    required this.side,
  });

  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final bool isActive;
  final EditorSidebarSide side;

  @override
  Widget build(BuildContext context) {
    final Color stripeColor = isActive
        ? AppColors.primaryAccent
        : Theme.of(context).colorScheme.outlineVariant;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => onDragStart(),
        onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
        onHorizontalDragEnd: (_) => onDragEnd(),
        onHorizontalDragCancel: onDragEnd,
        child: Container(
          width: _DrawingNotePageState._dragHandleWidth,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: isActive ? 8 : 4,
            height: 80,
            decoration: BoxDecoration(
              color: stripeColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ResizeTrend { none, expand, shrink }

class _DrawingScrollBehavior extends MaterialScrollBehavior {
  const _DrawingScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.mouse,
    PointerDeviceKind.unknown,
  };
}

class _PointerSettingsSheet extends StatefulWidget {
  const _PointerSettingsSheet();

  @override
  State<_PointerSettingsSheet> createState() => _PointerSettingsSheetState();
}

class _PointerSettingsSheetState extends State<_PointerSettingsSheet> {
  @override
  Widget build(BuildContext context) {
    final settings = PointerSettingsScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eingabegeräte',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              label: 'Stift',
              value: settings.allowStylus,
              onChanged: (v) => setState(() => settings.update(stylus: v)),
            ),
            _ToggleRow(
              label: 'Touch',
              value: settings.allowTouch,
              onChanged: (v) => setState(() => settings.update(touch: v)),
            ),
            _ToggleRow(
              label: 'Maus',
              value: settings.allowMouse,
              onChanged: (v) => setState(() => settings.update(mouse: v)),
            ),
            const Divider(height: 28),
            _ToggleRow(
              label: 'Automatisch auf Stift sperren',
              value: settings.autoLockOnStylus,
              onChanged: (v) => setState(() => settings.update(autoLock: v)),
            ),
            if (settings.stylusLocked) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => settings.resetStylusLock()),
                child: const Text('Stift-Sperre aufheben'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// Beschriftung.
  final String label;

  /// Aktueller Wert.
  final bool value;

  /// Callback bei Änderung.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    value: value,
    onChanged: onChanged,
  );
}
