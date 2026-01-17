import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Dialog to select the background paper style for a note.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// The initially selected paper style.
  final NotePaperStyle initialPaperStyle;

  /// Creates a new [PaperStyleSelectionDialog].
  const PaperStyleSelectionDialog({
    super.key,
    required this.initialPaperStyle,
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
    _selectedStyle = widget.initialPaperStyle;
  }

  void _submit() {
    Navigator.of(context).pop(_selectedStyle);
  }

  // Local helper to enforce Clean Architecture as per guidelines,
  // avoiding direct dependency on domain entity UI properties if possible,
  // though NotePaperStyle already has .icon.
  IconData _getStyleIcon(NotePaperStyle style) {
    switch (style) {
      case NotePaperStyle.plain:
        return Icons.crop_square;
      case NotePaperStyle.lined:
        return Icons.horizontal_rule;
      case NotePaperStyle.grid:
        return Icons.grid_3x3;
      case NotePaperStyle.dotted:
        return Icons.blur_on;
    }
  }

  String _getStyleLabel(BuildContext context, NotePaperStyle style) {
    // Strictly using localized keys instead of style.label
    switch (style) {
      case NotePaperStyle.plain:
        return context.t.paper.plain;
      case NotePaperStyle.lined:
        return context.t.paper.lined;
      case NotePaperStyle.grid:
        return context.t.paper.grid;
      case NotePaperStyle.dotted:
        return context.t.paper.dotted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header / Preview
              AspectRatio(
                aspectRatio: 16 / 9,
                child: NotePaperBackground(
                  paperStyle: _selectedStyle,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStyleLabel(context, _selectedStyle),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  context.t.notes.selectPaperStyle,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Selection Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: NotePaperStyle.values.length,
                  itemBuilder: (context, index) {
                    final style = NotePaperStyle.values[index];
                    final isSelected = style == _selectedStyle;

                    return InkWell(
                      onTap: () => setState(() => _selectedStyle = style),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getStyleIcon(style),
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStyleLabel(context, style),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

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
      ),
    );
  }
}
