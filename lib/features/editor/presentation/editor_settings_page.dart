import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Seite zur Konfiguration der Editor-bezogenen Einstellungen.
class EditorSettingsPage extends StatelessWidget {
  /// Erstellt eine neue [EditorSettingsPage].
  const EditorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final settings = EditorSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.settings.editorSettings)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AnimatedBuilder(
            animation: settings,
            builder: (context, _) {
            final current = settings.sidebarSide;
            final bool simplifierEnabled = settings.lineSimplifierEnabled;
            final double simplifierStrength = settings.lineSimplifierStrength;
            final double simplifierMinTol = settings.lineSimplifierMinTolerance;
            final bool debugModeEnabled = settings.debugModeEnabled;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            );
          },
        ),
      ),
    ));
  }
}
