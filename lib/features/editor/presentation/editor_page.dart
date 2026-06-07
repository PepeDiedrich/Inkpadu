import 'package:flutter/material.dart';

import 'package:inkpadu/features/notes/domain/note.dart';
import 'package:inkpadu/i18n/translations.g.dart';

/// Minimal text editor for viewing and editing a [Note].
class EditorPage extends StatefulWidget {
  /// Creates a new [EditorPage].
  const EditorPage({super.key, required this.initialNote, this.isNew = false});

  /// Note that should be displayed when the editor opens.
  final Note initialNote;

  /// Indicates whether the editor was opened for a freshly created note.
  final bool isNew;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote.title);
    _contentController = TextEditingController(
      text: widget.initialNote.content,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final updated = widget.initialNote.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.isNew ? context.t.editor.newNote : context.t.editor.editNote),
      actions: [
        TextButton(onPressed: _saveNote, child: Text(context.t.common.save)),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: context.t.editor.title,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            autofocus: widget.isNew,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: context.t.editor.writeNote,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              expands: true,
            ),
          ),
        ],
      ),
    ),
  );
}
