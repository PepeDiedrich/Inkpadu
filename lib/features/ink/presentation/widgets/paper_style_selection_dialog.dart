import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Ein Dialog zur Auswahl des Papierstils mit Live-Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen neuen Dialog zur Auswahl des Papierstils.
  const PaperStyleSelectionDialog({super.key, required this.initialStyle});

  /// Der initial ausgewählte Papierstil.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = Translations.of(context);

    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.paper.select,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Vorschau-Bereich
                AspectRatio(
                  aspectRatio: 1.5,
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
                // Auswahl-Grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: NotePaperStyle.values.map((style) {
                    final isSelected = style == _selectedStyle;
                    return ChoiceChip(
                      label: Text(_getLocalizedLabel(context, style)),
                      selected: isSelected,
                      avatar: Icon(style.icon, size: 18),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedStyle = style;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                // Aktionen
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(t.common.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_selectedStyle),
                      child: Text(t.common.confirm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedLabel(BuildContext context, NotePaperStyle style) {
    final t = Translations.of(context);
    return switch (style) {
      NotePaperStyle.plain => t.paper.plain,
      NotePaperStyle.lined => t.paper.lined,
      NotePaperStyle.grid => t.paper.grid,
      NotePaperStyle.dotted => t.paper.dotted,
    };
  }
}
