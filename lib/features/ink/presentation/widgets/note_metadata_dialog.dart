import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';

/// Ergebnis des Metadaten-Dialogs.
class NoteMetadataResult {
  /// Erstellt ein neues Ergebnis.
  const NoteMetadataResult({required this.title, required this.paperStyle});

  /// Gewählter Titel (unbeschnitten).
  final String title;

  /// Ausgewählter Papierstil.
  final NotePaperStyle paperStyle;
}

/// Öffnet einen Dialog zum Erstellen oder Bearbeiten der Notiz-Metadaten.
Future<NoteMetadataResult?> showNoteMetadataDialog(
  BuildContext context, {
  required String initialTitle,
  required NotePaperStyle initialPaperStyle,
  bool isEditing = false,
}) => showDialog<NoteMetadataResult>(
  context: context,
  builder: (context) => _NoteMetadataDialog(
    initialTitle: initialTitle,
    initialPaperStyle: initialPaperStyle,
    isEditing: isEditing,
  ),
);

class _NoteMetadataDialog extends StatefulWidget {
  const _NoteMetadataDialog({
    required this.initialTitle,
    required this.initialPaperStyle,
    required this.isEditing,
  });

  final String initialTitle;
  final NotePaperStyle initialPaperStyle;
  final bool isEditing;

  @override
  State<_NoteMetadataDialog> createState() => _NoteMetadataDialogState();
}

class _NoteMetadataDialogState extends State<_NoteMetadataDialog> {
  late final TextEditingController _controller;
  late NotePaperStyle _selectedStyle;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
    _selectedStyle = widget.initialPaperStyle;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      NoteMetadataResult(title: _controller.text, paperStyle: _selectedStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isEditing ? 'Notiz anpassen' : 'Notiz anlegen';
    final segments = NotePaperStyle.values
        .map(
          (style) => ButtonSegment<NotePaperStyle>(
            value: style,
            icon: Icon(style.icon, size: 16),
            label: Text(style.label),
          ),
        )
        .toList(growable: false);

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: Text(titleText),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'Titel (optional)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<NotePaperStyle>(
              segments: segments,
              selected: <NotePaperStyle>{_selectedStyle},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                final next = selection.first;
                if (next != _selectedStyle) {
                  setState(() => _selectedStyle = next);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.isEditing ? 'Speichern' : 'Weiter'),
        ),
      ],
    );
  }
}
