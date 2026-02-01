import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Dialog zur Auswahl eines Papierstils mit Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen Dialog zur Papierauswahl.
  const PaperStyleSelectionDialog({required this.initialStyle, super.key});

  /// Der initial ausgewählte Stil.
  final NotePaperStyle initialStyle;

  @override
  State<PaperStyleSelectionDialog> createState() =>
      _PaperStyleSelectionDialogState();
}

class _PaperStyleSelectionDialogState extends State<PaperStyleSelectionDialog> {
  late NotePaperStyle _currentStyle;

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.initialStyle;
  }

  void _submit() {
    Navigator.of(context).pop(_currentStyle);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = context.t;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.notes.selectPaperStyle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                t.common.preview,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: NotePaperBackground(
                  paperStyle: _currentStyle,
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                physics: const NeverScrollableScrollPhysics(),
                children: NotePaperStyle.values.map<Widget>((style) {
                  final isSelected = style == _currentStyle;
                  final label = switch (style) {
                    NotePaperStyle.plain => t.paper.plain,
                    NotePaperStyle.lined => t.paper.lined,
                    NotePaperStyle.grid => t.paper.grid,
                    NotePaperStyle.dotted => t.paper.dotted,
                  };

                  final child = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style.icon),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(label, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  );

                  return isSelected
                      ? FilledButton.tonal(
                          onPressed: () =>
                              setState(() => _currentStyle = style),
                          child: child,
                        )
                      : OutlinedButton(
                          onPressed: () =>
                              setState(() => _currentStyle = style),
                          child: child,
                        );
                }).toList(),
              ),
              const SizedBox(height: 24),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                overflowSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.common.cancel),
                  ),
                  FilledButton(onPressed: _submit, child: Text(t.common.apply)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
