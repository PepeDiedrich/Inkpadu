import 'package:ai_handwriting_app/features/ink/presentation/widgets/math_rich_text.dart';
import 'package:flutter/material.dart';

/// Header widget to display imported task text from PDFs.
///
/// Renders task text in a styled container with an icon and label.
class ImportedTaskHeader extends StatelessWidget {
  /// Creates an imported task header.
  const ImportedTaskHeader({super.key, required this.taskText});

  /// The task text extracted from PDF.
  final String taskText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with icon and title
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 18,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Aufgabe',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          // Task text content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: MathRichText(
              text: taskText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
