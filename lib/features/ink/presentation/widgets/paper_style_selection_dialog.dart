import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_background.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Dialog zur Auswahl des Papierhintergrunds mit Vorschau.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen neuen Dialog zur Auswahl des Papierstils.
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

  String _getLocalizedStyleName(BuildContext context, NotePaperStyle style) =>
      switch (style) {
        NotePaperStyle.plain => context.t.paper.plain,
        NotePaperStyle.lined => context.t.paper.lined,
        NotePaperStyle.grid => context.t.paper.grid,
        NotePaperStyle.dotted => context.t.paper.dotted,
      };

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.t.paper.selectBackground),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NotePaperBackground(
                    paperStyle: _selectedStyle,
                    child: Container(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Selection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: NotePaperStyle.values
                    .map(
                      (style) => ChoiceChip(
                        label: Text(_getLocalizedStyleName(context, style)),
                        selected: _selectedStyle == style,
                        onSelected: (selected) => selected
                            ? setState(() {
                                _selectedStyle = style;
                              })
                            : null,
                        avatar: Icon(style.icon, size: 18),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_selectedStyle),
            child: Text(context.t.common.confirm),
          ),
        ],
      );
}
