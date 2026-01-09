import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/note_paper_painter.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Ein Dialog zur Auswahl des Papierstils.
class PaperStyleSelectionDialog extends StatefulWidget {
  /// Erstellt einen neuen Dialog zur Auswahl des Papierstils.
  const PaperStyleSelectionDialog({
    super.key,
    required this.initialStyle,
    required this.onStyleSelected,
  });

  /// Der aktuell gewählte Stil.
  final NotePaperStyle initialStyle;

  /// Callback, der aufgerufen wird, wenn ein neuer Stil bestätigt wurde.
  final ValueChanged<NotePaperStyle> onStyleSelected;

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
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.t.paper.selectStyle,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildPreview(context),
                  const SizedBox(height: 24),
                  _buildStyleGrid(context),
                  const SizedBox(height: 24),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color baseColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.15,
    );
    final Color accentColor = colorScheme.outlineVariant.withValues(alpha: 0.5);

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: baseColor,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: NotePaperPainter(
            style: _selectedStyle,
            lineColor: accentColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStyleGrid(BuildContext context) => GridView.count(
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
            onTap: () {
              setState(() {
                _selectedStyle = style;
              });
            },
          );
        }).toList(),
      );

  Widget _buildActions(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.common.cancel),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              widget.onStyleSelected(_selectedStyle);
              Navigator.of(context).pop();
            },
            child: Text(context.t.common.apply),
          ),
        ],
      );
}

class _StyleOptionButton extends StatelessWidget {
  const _StyleOptionButton({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  final NotePaperStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? colorScheme.primaryContainer : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(
              style.icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                style.label,
                style: TextStyle(
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
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
