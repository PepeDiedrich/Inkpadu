// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/utils/ai_prompt_util.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

class AiPromptEditorDialog extends StatefulWidget {
  final AiPrompt currentPrompt;
  final int index;
  final VoidCallback onSaved;

  const AiPromptEditorDialog({
    super.key,
    required this.currentPrompt,
    required this.index,
    required this.onSaved,
  });

  @override
  State<AiPromptEditorDialog> createState() => _AiPromptEditorDialogState();

  static void show(
    BuildContext context,
    AiPrompt currentPrompt,
    int index,
    VoidCallback onSaved,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AiPromptEditorDialog(
        currentPrompt: currentPrompt,
        index: index,
        onSaved: onSaved,
      ),
    );
  }
}

class _AiPromptEditorDialogState extends State<AiPromptEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentPrompt.title);
    _promptController = TextEditingController(
      text: widget.currentPrompt.prompt,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Shortcut ${widget.index + 1} bearbeiten'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _titleController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Titel'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _promptController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Prompt'),
          maxLines: 4,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.t.common.cancel),
      ),
      FilledButton(
        onPressed: () {
          final editorSettings = EditorSettingsScope.of(context);
          final currentPrompts = AiPromptUtil.resolveAiShortcuts(
            editorSettings.aiPrompts,
          );
          currentPrompts[widget.index] = AiPrompt(
            id: widget.currentPrompt.id,
            title: _titleController.text.trim(),
            prompt: _promptController.text.trim(),
          );
          editorSettings.update(aiPrompts: currentPrompts);
          Navigator.of(context).pop();
          widget.onSaved();
        },
        child: Text(context.t.common.save),
      ),
    ],
  );
}
