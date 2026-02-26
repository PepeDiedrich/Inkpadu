import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Seite zur Konfiguration der Editor-bezogenen Einstellungen.
class EditorSettingsPage extends StatelessWidget {
  /// Erstellt eine neue [EditorSettingsPage].
  const EditorSettingsPage({super.key});

  List<AiPrompt> _defaultAiShortcuts(BuildContext context) => <AiPrompt>[
    AiPrompt(
      id: 'ai-shortcut-1',
      title: context.t.editor.aiShortcut(index: 1),
      prompt: context.t.editor.aiShortcutPrompt1,
    ),
    AiPrompt(
      id: 'ai-shortcut-2',
      title: context.t.editor.aiShortcut(index: 2),
      prompt: context.t.editor.aiShortcutPrompt2,
    ),
    AiPrompt(
      id: 'ai-shortcut-3',
      title: context.t.editor.aiShortcut(index: 3),
      prompt: context.t.editor.aiShortcutPrompt3,
    ),
  ];

  List<AiPrompt> _normalizeAiShortcuts(
    BuildContext context,
    List<AiPrompt> source,
  ) {
    final defaults = _defaultAiShortcuts(context);
    final List<AiPrompt> normalized = <AiPrompt>[];
    for (var i = 0; i < 3; i++) {
      final fallback = defaults[i];
      final existing = i < source.length ? source[i] : fallback;
      final title = existing.title.trim().isEmpty ? fallback.title : existing.title;
      final prompt = existing.prompt.trim().isEmpty
          ? fallback.prompt
          : existing.prompt;
      normalized.add(AiPrompt(id: fallback.id, title: title, prompt: prompt));
    }
    return normalized;
  }

  bool _samePrompts(List<AiPrompt> a, List<AiPrompt> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].title != b[i].title ||
          a[i].prompt != b[i].prompt) {
        return false;
      }
    }
    return true;
  }

  Future<String?> _showSystemPromptDialog(
    BuildContext context,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.editor.editSystemPrompt),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: context.t.editor.systemPromptPlaceholder,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(context.t.common.save),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<AiPrompt?> _showShortcutDialog(
    BuildContext context,
    AiPrompt current,
    int index,
  ) async {
    final titleController = TextEditingController(text: current.title);
    final promptController = TextEditingController(text: current.prompt);
    final AiPrompt? result = await showDialog<AiPrompt>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.editor.editShortcut(index: index)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: context.t.editor.shortcutTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: promptController,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(labelText: context.t.editor.shortcutPrompt),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              final prompt = promptController.text.trim();
              if (title.isEmpty || prompt.isEmpty) {
                return;
              }
              Navigator.of(context).pop(
                AiPrompt(id: current.id, title: title, prompt: prompt),
              );
            },
            child: Text(context.t.common.save),
          ),
        ],
      ),
    );
    titleController.dispose();
    promptController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final settings = EditorSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.settings.editorSettings)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedBuilder(
          animation: settings,
          builder: (context, _) {
            final current = settings.sidebarSide;
            final bool simplifierEnabled = settings.lineSimplifierEnabled;
            final double simplifierStrength = settings.lineSimplifierStrength;
            final double simplifierMinTol = settings.lineSimplifierMinTolerance;
            final bool debugModeEnabled = settings.debugModeEnabled;
            final shortcutPrompts = _normalizeAiShortcuts(
              context,
              settings.aiPrompts,
            );
            if (!_samePrompts(shortcutPrompts, settings.aiPrompts)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                settings.update(aiPrompts: shortcutPrompts);
              });
            }
            return ListView(
              children: [
                Text(context.t.editor.assistPanel, style: textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<EditorSidebarSide>(
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    side: WidgetStateProperty.resolveWith(
                      (states) => BorderSide(
                        color: states.contains(WidgetState.selected)
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  segments: [
                    ButtonSegment<EditorSidebarSide>(
                      value: EditorSidebarSide.left,
                      icon: const Icon(Icons.keyboard_double_arrow_left),
                      label: Text(context.t.editor.leftRightHanded),
                    ),
                    ButtonSegment<EditorSidebarSide>(
                      value: EditorSidebarSide.right,
                      icon: const Icon(Icons.keyboard_double_arrow_right),
                      label: Text(context.t.editor.rightLeftHanded),
                    ),
                  ],
                  selected: <EditorSidebarSide>{current},
                  onSelectionChanged: (selection) =>
                      settings.update(sidebarSide: selection.first),
                ),
                const SizedBox(height: 12),
                Text(
                  context.t.editor.handednessHint,
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 32),
                Text(context.t.editor.drawingArea, style: textTheme.titleMedium),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.t.editor.enableDebugMode),
                  subtitle: Text(context.t.editor.debugModeHint),
                  value: debugModeEnabled,
                  onChanged: (value) =>
                      settings.update(debugModeEnabled: value),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.t.editor.useLineSimplifier),
                  subtitle: Text(context.t.editor.lineSimplifierHint),
                  value: simplifierEnabled,
                  onChanged: (value) =>
                      settings.update(lineSimplifierEnabled: value),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: simplifierEnabled ? 1 : 0.4,
                  child: IgnorePointer(
                    ignoring: !simplifierEnabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          context.t.editor.smoothingIntensity(value: simplifierStrength.toStringAsFixed(2)),
                          style: textTheme.bodyMedium,
                        ),
                        Slider.adaptive(
                          value: simplifierStrength.clamp(0.05, 0.8),
                          min: 0.1,
                          max: 0.6,
                          divisions: 10,
                          label: simplifierStrength.toStringAsFixed(2),
                          onChanged: (value) =>
                              settings.update(lineSimplifierStrength: value),
                        ),
                        Text(
                          context.t.editor.smoothingHint,
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.t.editor.minTolerance(value: simplifierMinTol.toStringAsFixed(2)),
                          style: textTheme.bodyMedium,
                        ),
                        Slider.adaptive(
                          value: simplifierMinTol.clamp(0.05, 1.5),
                          min: 0.1,
                          max: 1.2,
                          divisions: 11,
                          label: '${simplifierMinTol.toStringAsFixed(2)} px',
                          onChanged: (value) => settings.update(
                            lineSimplifierMinTolerance: value,
                          ),
                        ),
                        Text(
                          context.t.editor.minToleranceHint,
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(context.t.editor.yourSystemPrompt, style: textTheme.titleMedium),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.t.editor.editSystemPrompt),
                  subtitle: Text(
                    settings.aiSystemPrompt.trim().isEmpty
                        ? context.t.editor.systemPromptHint
                        : settings.aiSystemPrompt,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final String? edited = await _showSystemPromptDialog(
                      context,
                      settings.aiSystemPrompt,
                    );
                    if (edited == null) {
                      return;
                    }
                    settings.update(aiSystemPrompt: edited);
                  },
                ),
                const SizedBox(height: 32),
                Text(context.t.editor.aiShortcuts, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(context.t.editor.aiShortcutsHint, style: textTheme.bodySmall),
                const SizedBox(height: 8),
                for (var index = 0; index < shortcutPrompts.length; index++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(shortcutPrompts[index].title),
                    subtitle: Text(
                      shortcutPrompts[index].prompt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final edited = await _showShortcutDialog(
                        context,
                        shortcutPrompts[index],
                        index + 1,
                      );
                      if (edited == null) {
                        return;
                      }
                      final List<AiPrompt> updated = List<AiPrompt>.from(
                        shortcutPrompts,
                      );
                      updated[index] = edited;
                      settings.update(aiPrompts: updated);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
