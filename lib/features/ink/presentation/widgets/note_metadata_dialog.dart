import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/widgets/paper_style_selection_dialog.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

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

  Future<void> _pickPaperStyle() async {
    final result = await showPaperStyleSelectionDialog(
      context,
      initialStyle: _selectedStyle,
    );
    if (result != null) {
      setState(() => _selectedStyle = result);
    }
  }

  String _getLocalizedLabel(NotePaperStyle style) => switch (style) {
        NotePaperStyle.plain => context.t.paper.plain,
        NotePaperStyle.lined => context.t.paper.lined,
        NotePaperStyle.grid => context.t.paper.grid,
        NotePaperStyle.dotted => context.t.paper.dotted,
      };

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isEditing
        ? context.t.notes.adjustTitlePaper
        : context.t.notes.newNote;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: context.t.common.cancel,
          icon: const Icon(Icons.close),
        ),
        title: Text(titleText),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(widget.isEditing ? context.t.common.save : context.t.common.next),
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
                key: const PageStorageKey('note_metadata_dialog_list'),
                padding: const EdgeInsets.symmetric(vertical: 32),
                children: [
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: context.t.editor.title,
                      hintText: '${context.t.editor.title} (${context.t.common.no})',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Paper style',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(_getLocalizedLabel(_selectedStyle)),
                    leading: Icon(_selectedStyle.icon),
                    trailing: const Icon(Icons.chevron_right),
                    tileColor: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    onTap: _pickPaperStyle,
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
                child: Text(context.t.common.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _submit,
                child: Text(widget.isEditing ? context.t.common.save : context.t.common.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
