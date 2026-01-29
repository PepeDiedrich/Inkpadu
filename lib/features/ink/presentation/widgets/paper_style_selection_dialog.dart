import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Dialog zur Auswahl des Papierhintergrunds mit Live-Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen neuen Auswahldialog.
  const PaperStyleSelectionDialog({super.key, required this.initialStyle});

  /// Der aktuell ausgewählte (oder initiale) Stil.
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

  void _onStyleSelected(NotePaperStyle style) {
    setState(() {
      _selectedStyle = style;
    });
  }

  void _onConfirm() {
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

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                context.t.paper.chooseStyle,
                style: theme.textTheme.headlineSmall,
              ),
            ),

            // Preview Area
            SizedBox(
              height: 200,
              child: NotePaperBackground(
                paperStyle: _selectedStyle,
                child: const SizedBox.expand(),
              ),
            ),

            const Divider(height: 1),

            // Selection Grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: NotePaperStyle.values
                    .map(
                      (style) => ChoiceChip(
                        label: Text(_getLocalizedLabel(style)),
                        avatar: Icon(style.icon, size: 18),
                        selected: _selectedStyle == style,
                        onSelected: (selected) =>
                            selected ? _onStyleSelected(style) : null,
                      ),
                    )
                    .toList(),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.t.common.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _onConfirm,
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
