// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:inkpadu/features/editor/application/editor_settings_scope.dart';
import 'package:inkpadu/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/utils/ai_prompt_util.dart';
import 'package:inkpadu/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/components/ai_prompt_editor_dialog.dart';

class AiLassoShortcutsView extends StatelessWidget {
  final bool isLoading;
  final ValueChanged<AiPrompt> onExecuteShortcut;
  final VoidCallback? onExecuteGraph;
  final VoidCallback onStateUpdate;

  const AiLassoShortcutsView({
    super.key,
    required this.isLoading,
    required this.onExecuteShortcut,
    this.onExecuteGraph,
    required this.onStateUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final editorSettings = EditorSettingsScope.of(context);
    final aiShortcuts = AiPromptUtil.resolveAiShortcuts(
      editorSettings.aiPrompts,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < aiShortcuts.length; i++)
          FilledButton.tonalIcon(
            onPressed: isLoading
                ? null
                : () => onExecuteShortcut(aiShortcuts[i]),
            onLongPress: () => AiPromptEditorDialog.show(
              context,
              aiShortcuts[i],
              i,
              onStateUpdate,
            ),
            icon: const Icon(Icons.flash_on, size: 16),
            label: Text(aiShortcuts[i].title),
          ),
        if (onExecuteGraph != null)
          FilledButton.tonalIcon(
            onPressed: isLoading ? null : () => onExecuteGraph!(),
            icon: const Icon(Icons.bar_chart),
            label: const Text("Graph"),
          ),
      ],
    );
  }
}
