import 'package:flutter/material.dart';

import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Dialog zur Auswahl des Papierhintergrunds mit Live-Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen neuen Auswahldialog.
  const PaperStyleSelectionDialog({super.key, required this.initialStyle});

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

  String _getStyleLabel(BuildContext context, NotePaperStyle style) =>
      switch (style) {
        NotePaperStyle.plain => context.t.paper.plain,
        NotePaperStyle.lined => context.t.paper.lined,
        NotePaperStyle.grid => context.t.paper.grid,
        NotePaperStyle.dotted => context.t.paper.dotted,
      };

  IconData _getStyleIcon(NotePaperStyle style) => switch (style) {
    NotePaperStyle.plain => Icons.crop_square,
    NotePaperStyle.lined => Icons.horizontal_rule,
    NotePaperStyle.grid => Icons.grid_3x3,
    NotePaperStyle.dotted => Icons.blur_on,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  context.t.paper.chooseBackground,
                  style: theme.textTheme.headlineSmall,
                ),
              ),

              // Vorschau-Bereich
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: NotePaperBackground(
                    paperStyle: _currentStyle,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Auswahl-Bereich
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: NotePaperStyle.values.map((style) {
                    final isSelected = style == _currentStyle;
                    return ChoiceChip(
                      showCheckmark: false,
                      avatar: Icon(
                        _getStyleIcon(style),
                        size: 18,
                        color: isSelected ? colorScheme.onPrimary : null,
                      ),
                      label: Text(_getStyleLabel(context, style)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _currentStyle = style);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Aktionen
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
                      onPressed: () => Navigator.of(context).pop(_currentStyle),
                      child: Text(context.t.common.confirm),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
