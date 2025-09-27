import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
  final List<Offset> _currentPath = [];
  bool _isDrawing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = InkNotesScope.of(context);
    final idx = controller.notes.indexWhere((n) => n.id == widget.noteId);
    if (idx == -1) {
      // Fallback: Notiz existiert nicht (evtl. gelöscht oder inkonsistenter Zustand)
      // Wir erzeugen eine leere Platzhalter-Notiz mit derselben ID, damit die Seite funktionsfähig bleibt.
      debugPrint(
        'Warnung: Notiz mit ID ${widget.noteId} nicht gefunden. Erzeuge Platzhalter.',
      );
      final placeholder = InkNote(
        id: widget.noteId,
        title: 'Fehlende Notiz',
        updatedAt: DateTime.now(),
        strokes: const <List<Offset>>[],
      );
      controller.upsert(placeholder);
      _note = placeholder;
    } else {
      _note = controller.notes[idx];
    }
  }

  void _start(DragStartDetails details) {
    final settings = PointerSettingsScope.of(context);
    final kind = details.kind ?? PointerDeviceKind.touch; // Fallback
    if (!settings.accept(kind)) return;
    settings.register(kind);
    setState(() {
      _isDrawing = true;
      _currentPath
        ..clear()
        ..add(details.localPosition);
    });
  }

  void _update(DragUpdateDetails details) {
    if (!_isDrawing) return;
    setState(() => _currentPath.add(details.localPosition));
  }

  void _end(DragEndDetails details) {
    if (!_isDrawing || _currentPath.length < 2) {
      setState(() => _isDrawing = false);
      return;
    }
    final controller = InkNotesScope.of(context);
    final updated = _note.copyWith(
      strokes: List<List<Offset>>.from(_note.strokes)
        ..add(List<Offset>.from(_currentPath)),
      updatedAt: DateTime.now(),
    );
    controller.upsert(updated);
    _note = updated;
    setState(() {
      _currentPath.clear();
      _isDrawing = false;
    });
  }

  void _clear() {
    final controller = InkNotesScope.of(context);
    final cleared = _note.copyWith(
      strokes: <List<Offset>>[],
      updatedAt: DateTime.now(),
    );
    controller.upsert(cleared);
    setState(() => _note = cleared);
  }

  void _openPointerSettings() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const _PointerSettingsSheet(),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: Text(_note.title),
      actions: [
        IconButton(
          onPressed: _openPointerSettings,
          icon: const Icon(Icons.tune),
        ),
        IconButton(
          onPressed: _note.strokes.isEmpty && _currentPath.isEmpty
              ? null
              : _clear,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onPanStart: _start,
        onPanUpdate: _update,
        onPanEnd: _end,
        child: Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
          child: CustomPaint(
            painter: DrawingPainter(
              paths: [..._note.strokes],
              currentPath: _currentPath,
              strokeColor: Theme.of(context).colorScheme.onSurface,
              strokeWidth: 3.2,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Eingabegeräte', style: Theme.of(context).textTheme.titleMedium),
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
