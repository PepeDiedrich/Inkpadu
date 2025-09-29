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
  builder: (context) => Dialog.fullscreen(
    child: _NoteMetadataDialog(
      initialTitle: initialTitle,
      initialPaperStyle: initialPaperStyle,
      isEditing: isEditing,
    ),
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Abbrechen',
          icon: const Icon(Icons.close),
        ),
        title: Text(titleText),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(widget.isEditing ? 'Speichern' : 'Weiter'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 32),
                children: [
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Titel',
                      hintText: 'Titel (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Papierstil',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
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
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _submit,
                child: Text(widget.isEditing ? 'Speichern' : 'Weiter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
