import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// A dialog to select the paper style for a note.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Creates a new [PaperStyleSelectionDialog].
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

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.t.notes.chooseBackground),
    content: SizedBox(
      width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Preview Area
                AspectRatio(
                  aspectRatio: 1.6, // Landscape-ish preview
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: NotePaperBackground(
                      paperStyle: _selectedStyle,
                      child: const SizedBox.expand(),
                    ),
              ),
            ),
                const SizedBox(height: 24),
                // Style Grid
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: NotePaperStyle.values.map((style) {
                    final isSelected = style == _selectedStyle;
                    return _StyleOptionButton(
                      style: style,
                      isSelected: isSelected,
                      onSelected: () => setState(() => _selectedStyle = style),
                    );
                  }).toList(),
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
      FilledButton(onPressed: _submit, child: Text(context.t.common.apply)),
    ],
  );
}

class _StyleOptionButton extends StatelessWidget {
  const _StyleOptionButton({
    required this.style,
    required this.isSelected,
    required this.onSelected,
  });

  final NotePaperStyle style;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use localized labels based on the style
    final label = switch (style) {
      NotePaperStyle.plain => context.t.paper.plain,
      NotePaperStyle.lined => context.t.paper.lined,
      NotePaperStyle.grid => context.t.paper.grid,
      NotePaperStyle.dotted => context.t.paper.dotted,
    };

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(
              style.icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
