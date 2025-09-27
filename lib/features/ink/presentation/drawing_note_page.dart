import 'package:ai_handwriting_app/features/drawing/application/stroke_simplifier.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';

/// Verwaltet den Zustand der Zeichenfläche und stellt Undo/Redo-Funktionen bereit.
class DrawingController extends ChangeNotifier {
  /// Aktuell gezeichnete Striche.
  List<Stroke> _strokes = const [];

  /// Der temporäre Strich, der gerade entsteht.
  Stroke? _currentStroke;

  /// Stack für Wiederherstellen-Operationen.
  final List<Stroke> _redoStack = [];

  /// Liefert eine unveränderliche Sicht auf alle gespeicherten Striche.
  List<Stroke> get strokes => List.unmodifiable(_strokes);

  /// Gibt den aktuell entstehenden Strich zurück.
  Stroke? get currentStroke => _currentStroke;

  /// `true`, wenn mindestens ein Strich rückgängig gemacht werden kann.
  bool get canUndo => _strokes.isNotEmpty;

  /// `true`, wenn ein rückgängig gemachter Strich wiederhergestellt werden kann.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Übernimmt eine bestehende Liste von Strichen in den Controller.
  void initialize(List<Stroke> initialStrokes) {
    _strokes = List<Stroke>.of(initialStrokes);
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
  bool endStroke() {
    if (_currentStroke == null) {
      return false;
    }

    final stroke = _currentStroke!;
    _currentStroke = null;

    if (stroke.points.length < 2) {
      notifyListeners();
      return false;
    }

    final simplified = simplifyStroke(
      stroke,
      tolerance: _simplificationToleranceFor(stroke),
    );

    if (simplified.points.length < 2) {
      notifyListeners();
      return false;
    }

    _strokes = List<Stroke>.of(_strokes)..add(simplified);
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
    notifyListeners();
    return true;
  }

  /// Stellt den zuletzt rückgängig gemachten Strich wieder her.
  bool redo() {
    if (_redoStack.isEmpty) return false;

    final stroke = _redoStack.removeLast();
    _strokes = List<Stroke>.of(_strokes)..add(stroke);
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
    final effective = stroke.baseWidth * 0.35;
    const minTolerance = 0.5;
    return effective < minTolerance ? minTolerance : effective;
  }
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
    _drawingController.initialize(_note.page.strokes);
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  void _start(PointerDownEvent details) {
    final settings = PointerSettingsScope.of(context);
    final kind = details.kind;
    if (!settings.accept(kind)) return;
    settings.register(kind);

    final newPoint = DrawingPoint(
      position: details.localPosition,
      pressure: details.pressure,
    );

    _drawingController.startStroke(
      newPoint,
      color: Colors.amber,
      baseWidth: 6.0,
    );
  }

  void _update(PointerMoveEvent details) {
    if (_drawingController.currentStroke == null || !details.down) {
      return;
    }

    final newPoint = DrawingPoint(
      position: details.localPosition,
      pressure: details.pressure,
    );

    _drawingController.updateStroke(newPoint);
  }

  void _end(PointerUpEvent details) {
    if (_drawingController.endStroke()) {
      _persistDrawing();
    }
  }

  void _cancel(PointerCancelEvent details) {
    _drawingController.cancelCurrentStroke();
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
      });
    }
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
      builder: (context, constraints) => Listener(
        onPointerDown: _start,
        onPointerMove: _update,
        onPointerUp: _end,
        onPointerCancel: _cancel,
        child: Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
          child: AnimatedBuilder(
            animation: _drawingController,
            builder: (context, child) => Stack(
              children: [
                CustomPaint(
                  painter: DrawingPainter(strokes: _drawingController.strokes),
                ),
                CustomPaint(
                  painter: DrawingPainter(
                    currentStroke: _drawingController.currentStroke,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
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
