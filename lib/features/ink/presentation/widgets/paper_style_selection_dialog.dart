import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Ein Dialog zur Auswahl des Papierstils (Hintergrund).
///
/// Zeigt eine Live-Vorschau des gewählten Stils an.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen Dialog zur Papierauswahl.
  const PaperStyleSelectionDialog({
    super.key,
    required this.initialStyle,
  });

  /// Der anfänglich ausgewählte Stil.
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

  @override
  Widget build(BuildContext context) {
    // Verwendung von 't' für lokalisierte Strings.
    final t = Translations.of(context);

    return AlertDialog(
      title: Text(t.paper.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vorschau-Bereich
            _PreviewSection(style: _currentStyle),
            const SizedBox(height: 24),
            // Auswahl-Bereich
            _StyleSelector(
              currentStyle: _currentStyle,
              onStyleSelected: (style) => setState(() => _currentStyle = style),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_currentStyle),
          child: Text(t.common.save),
        ),
      ],
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.style,
  });

  final NotePaperStyle style;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: NotePaperBackground(
              paperStyle: style,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
}

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({
    required this.currentStyle,
    required this.onStyleSelected,
  });

  final NotePaperStyle currentStyle;
  final ValueChanged<NotePaperStyle> onStyleSelected;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: NotePaperStyle.values.map((style) {
        final isSelected = style == currentStyle;
        return InkWell(
          onTap: () => onStyleSelected(style),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStyleIcon(style),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  _getStyleName(style, t),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getStyleName(NotePaperStyle style, Translations t) => switch (style) {
        NotePaperStyle.plain => t.paper.plain,
        NotePaperStyle.lined => t.paper.lined,
        NotePaperStyle.grid => t.paper.grid,
        NotePaperStyle.dotted => t.paper.dotted,
      };

  IconData _getStyleIcon(NotePaperStyle style) => switch (style) {
        NotePaperStyle.plain => Icons.crop_square,
        NotePaperStyle.lined => Icons.format_align_justify,
        NotePaperStyle.grid => Icons.grid_3x3,
        NotePaperStyle.dotted => Icons.blur_on,
      };
}
