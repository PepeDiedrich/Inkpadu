import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';

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
      appBar: AppBar(title: const Text('Editor-Einstellungen')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedBuilder(
          animation: settings,
          builder: (context, _) {
            final current = settings.sidebarSide;
            final bool simplifierEnabled = settings.lineSimplifierEnabled;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assistenz-Panel', style: textTheme.titleMedium),
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
                  segments: const [
                    ButtonSegment<EditorSidebarSide>(
                      value: EditorSidebarSide.left,
                      icon: Icon(Icons.keyboard_double_arrow_left),
                      label: Text('Links · Rechtshänder'),
                    ),
                    ButtonSegment<EditorSidebarSide>(
                      value: EditorSidebarSide.right,
                      icon: Icon(Icons.keyboard_double_arrow_right),
                      label: Text('Rechts · Linkshänder'),
                    ),
                  ],
                  selected: <EditorSidebarSide>{current},
                  onSelectionChanged: (selection) =>
                      settings.update(sidebarSide: selection.first),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rechtshänder:innen erreichen die Tools bequemer, wenn das Panel links sitzt. '
                  'Linkshänder:innen wählen dagegen die rechte Seite.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 32),
                Text('Zeichenfläche', style: textTheme.titleMedium),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Linien-Simplifier verwenden'),
                  subtitle: const Text(
                    'Glättet deine Striche automatisch, um ruhige Linien zu erhalten.',
                  ),
                  value: simplifierEnabled,
                  onChanged: (value) =>
                      settings.update(lineSimplifierEnabled: value),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
