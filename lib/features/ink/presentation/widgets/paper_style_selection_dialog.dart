import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Dialog zur Auswahl des Papierhintergrunds mit Live-Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen Dialog zur Papierauswahl.
  const PaperStyleSelectionDialog({
    super.key,
    required this.initialStyle,
  });

  /// Der initial ausgewählte Stil.
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

  @override
  Widget build(BuildContext context) {
    // Verwendung von Dialog statt AlertDialog für mehr Kontrolle über das Layout
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header / Vorschau
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NotePaperBackground(
                      paperStyle: _selectedStyle,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  // Overlay Titel für besseren Kontrast/Kontext?
                  // Oder einfach nur als reine Vorschau lassen.
                  // Ich lasse es rein visuell.
                ],
              ),
            ),
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.t.notes.adjustTitlePaper,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Grid-Auswahl
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: NotePaperStyle.values.map((style) {
                          final isSelected = style == _selectedStyle;
                          return ChoiceChip(
                            label: Text(_getLabel(context, style)),
                            avatar: Icon(style.icon, size: 18),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedStyle = style);
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.t.common.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
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

  String _getLabel(BuildContext context, NotePaperStyle style) {
    return switch (style) {
      NotePaperStyle.plain => context.t.paper.plain,
      NotePaperStyle.lined => context.t.paper.lined,
      NotePaperStyle.grid => context.t.paper.grid,
      NotePaperStyle.dotted => context.t.paper.dotted,
    };
  }
}
