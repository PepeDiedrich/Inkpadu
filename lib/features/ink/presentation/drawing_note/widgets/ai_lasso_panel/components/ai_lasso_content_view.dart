// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:inkpadu/features/editor/application/editor_settings_scope.dart';
import 'package:inkpadu/features/ink/presentation/widgets/math_rich_text.dart';
import 'package:inkpadu/i18n/translations.g.dart';
import 'package:inkpadu/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/components/ai_lasso_shortcuts_view.dart';

class AiLassoContentView extends StatelessWidget {
  final bool isLoading;
  final String? answer;
  final String? generatedHtml;
  final int boxCount;
  final ValueChanged<AiPrompt> onExecuteShortcut;
  final VoidCallback? onExecuteGraph;
  final ValueChanged<String>? onGenerateGraph;
  final VoidCallback? onKeepHighlights;
  final VoidCallback onStateUpdate;
  final VoidCallback onClose;

  const AiLassoContentView({
    super.key,
    required this.isLoading,
    required this.answer,
    required this.generatedHtml,
    required this.boxCount,
    required this.onExecuteShortcut,
    this.onExecuteGraph,
    this.onGenerateGraph,
    this.onKeepHighlights,
    required this.onStateUpdate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AiLassoShortcutsView(
        isLoading: isLoading,
        onExecuteShortcut: onExecuteShortcut,
        onExecuteGraph: onExecuteGraph,
        onStateUpdate: onStateUpdate,
      ),
      const SizedBox(height: 12),

      // "Add graph to canvas" button
      if (!isLoading && generatedHtml != null && onGenerateGraph != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => onGenerateGraph?.call(generatedHtml!),
              icon: const Icon(Icons.add_box),
              label: const Text('Graph zum Canvas hinzufügen'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.tertiaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ),

      // "Keep highlights" button
      if (!isLoading &&
          answer != null &&
          onKeepHighlights != null &&
          boxCount > 0)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () {
                onKeepHighlights?.call();
                onClose();
              },
              icon: const Icon(Icons.playlist_add_check),
              label: Text(context.t.common.apply),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),

      if (isLoading)
        Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(context.t.ai.analyzingSelection),
          ],
        )
      else if (answer != null)
        MathRichText(text: answer!),
      const SizedBox(height: 12),
    ],
  );
}
