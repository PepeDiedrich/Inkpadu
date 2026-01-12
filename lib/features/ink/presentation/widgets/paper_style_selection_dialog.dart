import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Ein Dialog zur Auswahl des Papierstils mit einer Live-Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Der aktuell ausgewählte Papierstil, mit dem der Dialog initialisiert wird.
  final NotePaperStyle initialStyle;

  /// Erstellt einen Dialog zur Auswahl des Papierstils.
  const PaperStyleSelectionDialog({
    super.key,
    required this.initialStyle,
  });

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
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.paper.selectionTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              _buildPreview(),
              const SizedBox(height: 24),
              _buildSelectionGrid(),
              const SizedBox(height: 24),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: NotePaperBackground(
        paperStyle: _selectedStyle,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildSelectionGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: NotePaperStyle.values.length,
      itemBuilder: (context, index) {
        final style = NotePaperStyle.values[index];
        final isSelected = style == _selectedStyle;
        final colorScheme = Theme.of(context).colorScheme;

        return Material(
          color:
              isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedStyle = style;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  style.icon,
                  size: 20,
                  color:
                      isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  style.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedStyle),
          child: Text(t.common.apply),
        ),
      ],
    );
  }
}
