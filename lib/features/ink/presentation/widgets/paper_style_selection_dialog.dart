import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/features/ink/presentation/extensions/note_paper_style_extensions.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';

/// Ein Dialog zur Auswahl des Papierstils mit einer visuellen Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen Dialog zur Auswahl des Papierstils.
  const PaperStyleSelectionDialog({super.key, required this.initialStyle});

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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Text(
                  context.t.paper.select,
                  style: theme.textTheme.headlineSmall,
                ),
              ),

              // Preview Area
              AspectRatio(
                aspectRatio:
                    1.414, // A4 Landscape ratio approximation or just generic
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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

              const SizedBox(height: 12),

              // Selection Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children:
                      NotePaperStyle.values.map((style) {
                        final isSelected = style == _currentStyle;
                        return ChoiceChip(
                    label: Text(style.localizedLabel(context)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _currentStyle = style);
                          },
                          avatar: Icon(style.icon, size: 18),
                        );
                      }).toList(),
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

/// Helper function to show the dialog
Future<NotePaperStyle?> showPaperStyleSelectionDialog(
  BuildContext context, {
  required NotePaperStyle initialStyle,
}) => showDialog<NotePaperStyle>(
  context: context,
  builder: (context) => PaperStyleSelectionDialog(initialStyle: initialStyle),
);
