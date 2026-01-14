import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Ein Dialog zur Auswahl des Papierstils mit Live-Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen Dialog zur Auswahl des Papierstils.
  const PaperStyleSelectionDialog({super.key, required this.initialPaperStyle});

  /// Der aktuell gewählte Papierstil beim Öffnen des Dialogs.
  final NotePaperStyle initialPaperStyle;

  @override
  State<PaperStyleSelectionDialog> createState() =>
      _PaperStyleSelectionDialogState();
}

class _PaperStyleSelectionDialogState extends State<PaperStyleSelectionDialog> {
  late NotePaperStyle _selectedStyle;

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.initialPaperStyle;
  }

  String _getLocalizedLabel(BuildContext context, NotePaperStyle style) =>
      switch (style) {
        NotePaperStyle.plain => context.t.paper.plain,
        NotePaperStyle.lined => context.t.paper.lined,
        NotePaperStyle.grid => context.t.paper.grid,
        NotePaperStyle.dotted => context.t.paper.dotted,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                context.t.notes.chooseBackground,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: NotePaperBackground(
                  paperStyle: _selectedStyle,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: NotePaperStyle.values.length,
                    itemBuilder: (context, index) {
                      final style = NotePaperStyle.values[index];
                      final isSelected = style == _selectedStyle;

                      return InkWell(
                        onTap: () => setState(() => _selectedStyle = style),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : null,
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                style.icon,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getLocalizedLabel(context, style),
                                style: TextStyle(
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.t.common.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selectedStyle),
                    child: Text(context.t.common.apply),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
