import 'dart:async';
import 'dart:convert';
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
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  double _simplifierStrength = 0.25;
  double _simplifierMinTolerance = 0.3;

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

  /// Entfernt Striche, deren Punkte innerhalb des gegebenen Radius liegen.
  bool eraseAt(Offset position, {required double radius}) {
    if (_strokes.isEmpty) {
      return false;
    }

    final double radiusSquared = radius * radius;
    final List<Stroke> retained = <Stroke>[];
    var removedAny = false;

    for (final stroke in _strokes) {
      final bool shouldRemove = stroke.points.any((point) {
        final double dx = point.position.dx - position.dx;
        final double dy = point.position.dy - position.dy;
        return (dx * dx + dy * dy) <= radiusSquared;
      });

      if (shouldRemove) {
        removedAny = true;
      } else {
        retained.add(stroke);
      }
    }

    if (!removedAny) {
      return false;
    }

    _strokes = List<Stroke>.of(retained);
    _redoStack.clear();
    _strokesVersion++;
    notifyListeners();
    return true;
  }

  /// Aktualisiert die Parameter des Linien-Vereinfachers.
  ///
  /// [strength] steuert die relative Stärke der Vereinfachung und wird zwischen
  /// `0.05` und `0.8` geklemmt. [minTolerance] definiert die Mindesttoleranz und
  /// kann nicht unter `0.05` fallen.
  void updateSimplifierSettings({double? strength, double? minTolerance}) {
    if (strength != null) {
      final double clamped = strength.clamp(0.05, 0.8);
      _simplifierStrength = clamped;
    }
    if (minTolerance != null) {
      final double clamped = minTolerance.clamp(0.05, double.infinity);
      _simplifierMinTolerance = clamped;
    }
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
    final effective = stroke.baseWidth * _simplifierStrength;
    final minTolerance = _simplifierMinTolerance;
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
  late final _ToolPreferencesStore _toolPreferencesStore;
  late List<_DrawingTool> _tools;
  late String _selectedToolId;
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
  String? _activeToolDuringStrokeId;
  bool _didEraseDuringDrag = false;
  static const List<Color> _defaultToolColors = [
    Colors.black,
    Color(0xFF424242),
    Color(0xFF1E88E5),
    Color(0xFF00897B),
    Color(0xFF7CB342),
    Color(0xFFFDD835),
    Color(0xFFFFA726),
    Color(0xFFE53935),
    Color(0xFF8E24AA),
    Color(0xFF6D4C41),
    Color(0xFF607D8B),
    Colors.white,
  ];

  static const List<_ToolIconOption> _toolIconOptions = <_ToolIconOption>[
    _ToolIconOption(icon: Icons.edit, label: 'Fineliner'),
    _ToolIconOption(icon: Icons.create, label: 'Tintenroller'),
    _ToolIconOption(icon: Icons.draw, label: 'Füller'),
    _ToolIconOption(icon: Icons.brush, label: 'Pinsel'),
    _ToolIconOption(icon: Icons.mode_edit_outline, label: 'Skizzieren'),
    _ToolIconOption(icon: Icons.gesture, label: 'Gesten'),
    _ToolIconOption(icon: Icons.edit_note, label: 'Notizen'),
    _ToolIconOption(icon: Icons.border_color, label: 'Marker'),
    _ToolIconOption(icon: Icons.highlight, label: 'Highlight'),
    _ToolIconOption(icon: Icons.auto_fix_high, label: 'Effekt'),
    _ToolIconOption(icon: Icons.colorize, label: 'Farbverlauf'),
    _ToolIconOption(icon: Icons.flash_on, label: 'Blitz'),
  ];

  _DrawingTool get _currentTool {
    if (_tools.isEmpty) {
      return const _DrawingTool(
        id: 'default',
        label: 'Standard',
        icon: Icons.edit,
        color: Colors.black,
        baseWidth: 4.5,
      );
    }
    return _tools.firstWhere(
      (tool) => tool.id == _selectedToolId,
      orElse: () => _tools.first,
    );
  }

  _DrawingTool _toolById(String? id) {
    if (id == null) {
      return _currentTool;
    }
    final index = _tools.indexWhere((tool) => tool.id == id);
    if (index == -1) {
      return _currentTool;
    }
    return _tools[index];
  }

  double _eraserRadiusForTool(_DrawingTool tool) =>
      math.max(tool.baseWidth * 0.6, 8);

  bool _applyEraserPoint(Offset position, _DrawingTool tool) =>
      _drawingController.eraseAt(position, radius: _eraserRadiusForTool(tool));

  void _selectTool(String toolId) {
    if (_selectedToolId == toolId) {
      return;
    }
    if (!_tools.any((tool) => tool.id == toolId)) {
      return;
    }
    setState(() {
      _selectedToolId = toolId;
    });
  }

  void _updateToolInList(_DrawingTool updatedTool) {
    setState(() {
      _tools = _tools
          .map((tool) => tool.id == updatedTool.id ? updatedTool : tool)
          .toList(growable: false);
    });
    _persistTools();
  }

  Future<void> _loadPersistedTools() async {
    final List<_DrawingTool> loaded = await _toolPreferencesStore.load(_tools);
    if (!mounted) {
      return;
    }
    setState(() {
      _tools = loaded;
      if (!_tools.any((tool) => tool.id == _selectedToolId)) {
        _selectedToolId = _tools.first.id;
      }
    });
  }

  void _persistTools() {
    unawaited(_toolPreferencesStore.save(_tools));
  }

  Color _toolDisplayColor(_DrawingTool tool) {
    if (tool.isEraser) {
      final colorScheme = Theme.of(context).colorScheme;
      return colorScheme.surfaceContainerHighest.withValues(alpha: 0.9);
    }
    if (tool.isHighlighter) {
      return tool.color.withValues(alpha: 0.45);
    }
    if (tool.color == Colors.white) {
      return tool.color.withValues(alpha: 0.9);
    }
    return tool.color;
  }

  Color _toolForegroundColor(Color background) {
    final Color opaque = background.a == 1
        ? background
        : background.withValues(alpha: 1);
    final brightness = ThemeData.estimateBrightnessForColor(opaque);
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  String _formatColorHex(Color color) {
    final int argb = color.toARGB32();
    final String rgb = argb.toRadixString(16).padLeft(8, '0').substring(2);
    return '#${rgb.toUpperCase()}';
  }

  double _pressureForEvent(PointerEvent event, _DrawingTool tool) {
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

  Widget _buildToolSelector() => Wrap(
    spacing: 8,
    runSpacing: 8,
    alignment: WrapAlignment.center,
    children: _tools
        .map((tool) => _buildToolChip(tool))
        .toList(growable: false),
  );

  Widget _buildToolChip(_DrawingTool tool) {
    final bool isSelected = tool.id == _selectedToolId;
    final Color displayColor = _toolDisplayColor(tool);
    final Color borderColor = isSelected
        ? AppColors.primaryAccent
        : tool.isEraser
        ? Theme.of(context).colorScheme.outline
        : displayColor.a < 1
        ? Theme.of(context).colorScheme.outline
        : Colors.transparent;
    final Color iconColor = _toolForegroundColor(displayColor);
    final tooltip = tool.isEraser
        ? '${tool.label} · ${tool.baseWidth.toStringAsFixed(1)} px'
        : '${tool.label} · ${tool.baseWidth.toStringAsFixed(1)} px';
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => _selectTool(tool.id),
        onLongPress: () => _openToolConfigurator(tool),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: displayColor,
            border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
          ),
          child: Center(
            child: Icon(
              tool.icon,
              size: 18,
              color: tool.isHighlighter
                  ? iconColor.withValues(alpha: 0.8)
                  : tool.isEraser
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : iconColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openToolConfigurator(_DrawingTool tool) async {
    final updated = await showModalBottomSheet<_DrawingTool>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        _DrawingTool draft = tool;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bool showColorPicker = !draft.isEraser;
            final bool showHighlighterToggle = !draft.isEraser;
            final bool showPressureToggle = !draft.isEraser;
            final double minWidth = draft.isEraser
                ? 8
                : draft.isHighlighter
                ? 6
                : 1;
            final double maxWidth = draft.isEraser
                ? 32
                : draft.isHighlighter
                ? 24
                : 12;
            final double sliderValue = draft.baseWidth.clamp(
              minWidth,
              maxWidth,
            );
            final theme = Theme.of(context);
            final ColorScheme colorScheme = theme.colorScheme;
            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tool.label} anpassen',
                    style: theme.textTheme.titleMedium,
                  ),
                  if (showColorPicker) ...[
                    const SizedBox(height: 16),
                    Text('Farbe', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _defaultToolColors
                          .map((color) {
                            final bool isActive = draft.color == color;
                            return GestureDetector(
                              onTap: () => setModalState(
                                () => draft = draft.copyWith(color: color),
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.primaryAccent
                                        : colorScheme.outlineVariant,
                                    width: isActive ? 3 : 1,
                                  ),
                                ),
                                child: isActive
                                    ? Icon(
                                        Icons.check,
                                        color:
                                            ThemeData.estimateBrightnessForColor(
                                                  color,
                                                ) ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 16),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Farbkreis',
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: 12),
                            ColorPicker(
                              pickerColor: draft.color,
                              onColorChanged: (Color color) => setModalState(
                                () => draft = draft.copyWith(color: color),
                              ),
                              enableAlpha: false,
                              paletteType: PaletteType.hueWheel,
                              displayThumbColor: true,
                              portraitOnly: true,
                              pickerAreaBorderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aktuelle Farbe: ${_formatColorHex(draft.color)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (!draft.isEraser) ...[
                    const SizedBox(height: 24),
                    Text('Symbol', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _toolIconOptions
                          .map((option) {
                            final bool isActive = option.icon == draft.icon;
                            return Tooltip(
                              message: option.label,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => setModalState(
                                  () =>
                                      draft = draft.copyWith(icon: option.icon),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.primaryAccent.withValues(
                                            alpha: 0.12,
                                          )
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isActive
                                          ? AppColors.primaryAccent
                                          : colorScheme.outlineVariant,
                                      width: isActive ? 2 : 1,
                                    ),
                                  ),
                                  child: Icon(
                                    option.icon,
                                    color: isActive
                                        ? AppColors.primaryAccent
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    draft.isEraser ? 'Radierbreite' : 'Linienstärke',
                    style: theme.textTheme.labelLarge,
                  ),
                  Slider.adaptive(
                    value: sliderValue,
                    min: minWidth,
                    max: maxWidth,
                    divisions: math.max(1, ((maxWidth - minWidth) * 2).round()),
                    label: '${sliderValue.toStringAsFixed(1)} px',
                    onChanged: (value) => setModalState(
                      () => draft = draft.copyWith(baseWidth: value),
                    ),
                  ),
                  if (showHighlighterToggle) ...[
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Marker-Modus (durchscheinend)'),
                      value: draft.isHighlighter,
                      onChanged: (value) => setModalState(() {
                        final double adjustedWidth = value
                            ? math.max(draft.baseWidth, 6).toDouble()
                            : draft.baseWidth.clamp(1, 12).toDouble();
                        draft = draft.copyWith(
                          isHighlighter: value,
                          baseWidth: adjustedWidth,
                        );
                      }),
                    ),
                  ],
                  if (showPressureToggle) ...[
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Druckerkennung'),
                      subtitle: Text(
                        'Steuert, ob Stiftdruck die Linienstärke beeinflusst.',
                        style: theme.textTheme.bodySmall,
                      ),
                      value: draft.usePressure,
                      onChanged: (value) => setModalState(
                        () => draft = draft.copyWith(usePressure: value),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Abbrechen'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, draft),
                        child: const Text('Übernehmen'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (updated != null) {
      _updateToolInList(updated);
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
    if (_activeDrawingPointerId == null) {
      return;
    }
    final tool = _toolById(_activeToolDuringStrokeId);
    if (tool.isEraser) {
      _didEraseDuringDrag = false;
    } else {
      _drawingController.cancelCurrentStroke();
    }
    _activeDrawingPointerId = null;
    _activeToolDuringStrokeId = null;
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
    _tools = [
      const _DrawingTool(
        id: 'pen-fineliner',
        label: 'Fineliner',
        icon: Icons.edit,
        color: Colors.black,
        baseWidth: 3.5,
      ),
      const _DrawingTool(
        id: 'pen-ink',
        label: 'Tintenroller',
        icon: Icons.create,
        color: Color(0xFF1E88E5),
        baseWidth: 4.5,
      ),
      const _DrawingTool(
        id: 'pen-fountain',
        label: 'Füller',
        icon: Icons.draw,
        color: Color(0xFFD32F2F),
        baseWidth: 5.5,
      ),
      const _DrawingTool(
        id: 'pen-marker',
        label: 'Marker',
        icon: Icons.brush,
        color: Color(0xFFFFC107),
        baseWidth: 11,
        isHighlighter: true,
        usePressure: false,
      ),
      const _DrawingTool(
        id: 'pen-neon',
        label: 'Neon',
        icon: Icons.highlight,
        color: Color(0xFF66BB6A),
        baseWidth: 8,
        isHighlighter: true,
        usePressure: false,
      ),
      const _DrawingTool(
        id: 'eraser',
        label: 'Radierer',
        icon: Icons.auto_fix_off,
        color: Colors.white,
        baseWidth: 18,
        isEraser: true,
        usePressure: false,
      ),
    ];
    _selectedToolId = _tools.first.id;
    _toolPreferencesStore = const _ToolPreferencesStore();
    unawaited(_loadPersistedTools());
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

    final tool = _currentTool;
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

    _drawingController.startStroke(
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

    final tool = _toolById(_activeToolDuringStrokeId);

    if (tool.isEraser) {
      final bool erased = _applyEraserPoint(details.localPosition, tool);
      if (erased) {
        _didEraseDuringDrag = true;
      }
      return;
    }

    if (_drawingController.currentStroke == null) {
      return;
    }

    final double pressure = _pressureForEvent(details, tool);
    final newPoint = DrawingPoint(
      position: details.localPosition,
      pressure: pressure,
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

    final tool = _toolById(_activeToolDuringStrokeId);
    _activeDrawingPointerId = null;
    _activeToolDuringStrokeId = null;

    if (tool.isEraser) {
      if (_didEraseDuringDrag) {
        _persistDrawing();
      }
      _didEraseDuringDrag = false;
      return;
    }

    _didEraseDuringDrag = false;

    final editorSettings = EditorSettingsScope.of(context);
    _drawingController.updateSimplifierSettings(
      strength: editorSettings.lineSimplifierStrength,
      minTolerance: editorSettings.lineSimplifierMinTolerance,
    );
    final bool simplify = editorSettings.lineSimplifierEnabled;
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
      final tool = _toolById(_activeToolDuringStrokeId);
      if (tool.isEraser) {
        _didEraseDuringDrag = false;
      } else {
        _drawingController.cancelCurrentStroke();
      }
      _activeDrawingPointerId = null;
      _activeToolDuringStrokeId = null;
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
      centerTitle: true,
      toolbarHeight: 94,
      titleSpacing: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _note.title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: _buildToolSelector(),
          ),
        ],
      ),
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
        const SizedBox(width: 8),
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

class _DrawingTool {
  const _DrawingTool({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.baseWidth,
    this.isHighlighter = false,
    this.isEraser = false,
    this.usePressure = true,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final double baseWidth;
  final bool isHighlighter;
  final bool isEraser;
  final bool usePressure;

  _DrawingTool copyWith({
    String? label,
    IconData? icon,
    Color? color,
    double? baseWidth,
    bool? isHighlighter,
    bool? isEraser,
    bool? usePressure,
  }) => _DrawingTool(
    id: id,
    label: label ?? this.label,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    baseWidth: baseWidth ?? this.baseWidth,
    isHighlighter: isHighlighter ?? this.isHighlighter,
    isEraser: isEraser ?? this.isEraser,
    usePressure: usePressure ?? this.usePressure,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'icon': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'iconFontPackage': icon.fontPackage,
    'iconMatchTextDirection': icon.matchTextDirection,
    'color': color.toARGB32(),
    'baseWidth': baseWidth,
    'isHighlighter': isHighlighter,
    'isEraser': isEraser,
    'usePressure': usePressure,
  };

  factory _DrawingTool.fromJson(Map<String, dynamic> json) => _DrawingTool(
    id: json['id'] as String,
    label: json['label'] as String,
    icon: IconData(
      json['icon'] as int,
      fontFamily: json['iconFontFamily'] as String?,
      fontPackage: json['iconFontPackage'] as String?,
      matchTextDirection: json['iconMatchTextDirection'] as bool? ?? false,
    ),
    color: Color(json['color'] as int),
    baseWidth: (json['baseWidth'] as num).toDouble(),
    isHighlighter: json['isHighlighter'] as bool? ?? false,
    isEraser: json['isEraser'] as bool? ?? false,
    usePressure: json['usePressure'] as bool? ?? true,
  );
}

class _ToolIconOption {
  const _ToolIconOption({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _ToolPreferencesStore {
  const _ToolPreferencesStore();

  static const String _storageKey = 'drawing_tools_v1';

  Future<List<_DrawingTool>> load(List<_DrawingTool> defaults) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_storageKey);
      if (raw == null) {
        return defaults;
      }
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return defaults;
      }
      final List<_DrawingTool> stored = <_DrawingTool>[];
      for (final dynamic entry in decoded) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        try {
          stored.add(_DrawingTool.fromJson(entry));
        } catch (error) {
          debugPrint(
            'Fehler beim Parsen eines gespeicherten Werkzeugs: $error',
          );
        }
      }
      if (stored.isEmpty) {
        return defaults;
      }
      return _mergeWithDefaults(defaults, stored);
    } catch (error) {
      debugPrint('Fehler beim Laden der Werkzeug-Voreinstellungen: $error');
      return defaults;
    }
  }

  Future<void> save(List<_DrawingTool> tools) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String payload = jsonEncode(
        tools.map((tool) => tool.toJson()).toList(growable: false),
      );
      await prefs.setString(_storageKey, payload);
    } catch (error) {
      debugPrint('Fehler beim Speichern der Werkzeug-Voreinstellungen: $error');
    }
  }

  List<_DrawingTool> _mergeWithDefaults(
    List<_DrawingTool> defaults,
    List<_DrawingTool> stored,
  ) => defaults
      .map((tool) {
        _DrawingTool? match;
        for (final _DrawingTool candidate in stored) {
          if (candidate.id == tool.id) {
            match = candidate;
            break;
          }
        }
        if (match == null) {
          return tool;
        }
        return _DrawingTool(
          id: tool.id,
          label: match.label,
          icon: match.icon,
          color: match.color,
          baseWidth: match.baseWidth,
          isHighlighter: tool.isHighlighter,
          isEraser: tool.isEraser,
          usePressure: match.usePressure,
        );
      })
      .toList(growable: false);
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
