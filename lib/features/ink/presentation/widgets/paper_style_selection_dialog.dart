import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Ein Dialog zur Auswahl des Papierstils mit visueller Vorschau.
Future<NotePaperStyle?> showPaperStyleSelectionDialog(
  BuildContext context, {
  required NotePaperStyle initialStyle,
}) => showDialog<NotePaperStyle>(
  context: context,
  builder: (context) => PaperStyleSelectionDialog(initialStyle: initialStyle),
);

/// Dialog content for selecting a paper style.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Creates a paper style selection dialog.
  const PaperStyleSelectionDialog({super.key, required this.initialStyle});

  /// The initially selected paper style.
  final NotePaperStyle initialStyle;

  @override
  State<PaperStyleSelectionDialog> createState() =>
      _PaperStyleSelectionDialogState();
}

class _PaperStyleSelectionDialogState extends State<PaperStyleSelectionDialog> {
  late NotePaperStyle _selectedStyle;

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.initialStyle;
  }

  void _submit() {
    Navigator.of(context).pop(_selectedStyle);
  }

  String _getLocalizedLabel(NotePaperStyle style) => switch (style) {
        NotePaperStyle.plain => context.t.paper.plain,
        NotePaperStyle.lined => context.t.paper.lined,
        NotePaperStyle.grid => context.t.paper.grid,
        NotePaperStyle.dotted => context.t.paper.dotted,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      scrollable: true,
      title: Text(context.t.notes.adjustTitlePaper),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview Area
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: NotePaperBackground(
                  paperStyle: _selectedStyle,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Selection Grid
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              children: NotePaperStyle.values.map((style) {
                  final isSelected = style == _selectedStyle;
                  return InkWell(
                    onTap: () => setState(() => _selectedStyle = style),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.secondaryContainer
                            : colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: colorScheme.primary, width: 2)
                            : Border.all(color: Colors.transparent),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            style.icon,
                            color: isSelected
                                ? colorScheme.onSecondaryContainer
                                : colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _getLocalizedLabel(style),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.t.common.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.t.common.apply),
        ),
      ],
    );
  }
}
