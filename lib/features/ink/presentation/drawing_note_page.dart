import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/drawing/presentation/drawing_painter.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/input/application/pointer_settings_scope.dart';

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
  Stroke? _currentStroke;
  bool _isDrawing = false;

  // Undo/Redo Stacks
  final List<Stroke> _redoStack = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = InkNotesScope.of(context);
    final idx = controller.notes.indexWhere((n) => n.id == widget.noteId);
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
      controller.upsert(placeholder);
      _note = placeholder;
    } else {
      _note = controller.notes[idx];
    }
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

    setState(() {
      _isDrawing = true;
      _currentStroke = Stroke(
        points: [newPoint],
        // Hier könnten Stift-Einstellungen aus einem Scope kommen
        color: Colors.amber,
        baseWidth: 6.0,
      );
      _redoStack.clear(); // Neues Zeichnen löscht den Redo-Verlauf
    });
  }

  void _update(PointerMoveEvent details) {
    if (!_isDrawing || _currentStroke == null) return;

    final newPoint = DrawingPoint(
      position: details.localPosition,
      pressure: details.pressure,
    );

    setState(() {
      _currentStroke = _currentStroke!.copyWith(
        points: List.from(_currentStroke!.points)..add(newPoint),
      );
    });
  }

  void _end(PointerUpEvent details) {
    if (!_isDrawing ||
        _currentStroke == null ||
        _currentStroke!.points.length < 2) {
      setState(() {
        _isDrawing = false;
        _currentStroke = null;
      });
      return;
    }

    final controller = InkNotesScope.of(context);
    final updatedPage = _note.page.copyWith(
      strokes: List.from(_note.page.strokes)..add(_currentStroke!),
    );
    final updatedNote = _note.copyWith(
      page: updatedPage,
      updatedAt: DateTime.now(),
    );

    controller.upsert(updatedNote);

    setState(() {
      _note = updatedNote;
      _currentStroke = null;
      _isDrawing = false;
    });
  }

  void _undo() {
    if (_note.page.strokes.isEmpty) return;

    final controller = InkNotesScope.of(context);
    final lastStroke = _note.page.strokes.last;

    final updatedPage = _note.page.copyWith(
      strokes: List.from(_note.page.strokes)..removeLast(),
    );
    final updatedNote = _note.copyWith(
      page: updatedPage,
      updatedAt: DateTime.now(),
    );

    controller.upsert(updatedNote);

    setState(() {
      _note = updatedNote;
      _redoStack.add(lastStroke);
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;

    final controller = InkNotesScope.of(context);
    final strokeToRedo = _redoStack.removeLast();

    final updatedPage = _note.page.copyWith(
      strokes: List.from(_note.page.strokes)..add(strokeToRedo),
    );
    final updatedNote = _note.copyWith(
      page: updatedPage,
      updatedAt: DateTime.now(),
    );

    controller.upsert(updatedNote);

    setState(() {
      _note = updatedNote;
    });
  }

  void _clear() {
    final controller = InkNotesScope.of(context);
    final cleared = _note.copyWith(
      page: NotePage(strokes: []),
      updatedAt: DateTime.now(),
    );
    controller.upsert(cleared);
    setState(() {
      _note = cleared;
      _redoStack.clear();
    });
  }

  // Pointer settings moved to Home (Notizen-Übersicht).

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: Text(_note.title),
      actions: [
        IconButton(
          onPressed: _undo,
          icon: const Icon(Icons.undo),
          tooltip: 'Undo',
        ),
        IconButton(
          onPressed: _redo,
          icon: const Icon(Icons.redo),
          tooltip: 'Redo',
        ),
        // Pointer settings removed from toolbar. Open them from Home.
        IconButton(
          onPressed: _note.page.strokes.isEmpty && _currentStroke == null
              ? null
              : _clear,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) => Listener(
        onPointerDown: _start,
        onPointerMove: _update,
        onPointerUp: _end,
        child: Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
          child: CustomPaint(
            painter: DrawingPainter(
              strokes: _note.page.strokes,
              currentStroke: _currentStroke,
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

extension on Stroke {
  Stroke copyWith({List<DrawingPoint>? points}) => Stroke(
    id: id,
    points: points ?? this.points,
    color: color,
    baseWidth: baseWidth,
    isHighlighter: isHighlighter,
  );
}

extension on NotePage {
  NotePage copyWith({List<Stroke>? strokes}) =>
      NotePage(strokes: strokes ?? this.strokes);
}
