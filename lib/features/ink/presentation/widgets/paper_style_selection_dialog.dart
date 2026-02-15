import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Dialog zur Auswahl des Papierstils mit Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen Dialog zur Auswahl des Papierstils.
  const PaperStyleSelectionDialog({
    super.key,
    required this.initialStyle,
  });

  /// Der initial ausgewählte Papierstil.
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

  String _getLocalizedStyleName(BuildContext context, NotePaperStyle style) =>
      switch (style) {
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
      title: Text(context.t.paper.title),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview
              SizedBox(
                height: 200,
                child: NotePaperBackground(
                  paperStyle: _currentStyle,
                  child: Center(
                    child: Text(
                      context.t.notes.noteDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              // Selection
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: NotePaperStyle.values.map((style) {
                    final isSelected = style == _currentStyle;
                    return InkWell(
                      onTap: () => setState(() => _currentStyle = style),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color:
                              isSelected
                                  ? colorScheme.primaryContainer
                                  : Colors.transparent,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              style.icon,
                              size: 20,
                              color:
                                  isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _getLocalizedStyleName(context, style),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color:
                                      isSelected
                                          ? colorScheme.onPrimaryContainer
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
              ),
            ],
          ),
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
