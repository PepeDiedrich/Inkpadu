import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_palette.dart';
import 'package:flutter/material.dart';

/// A floating window that contains drawing tools and actions.
class FloatingToolWindow extends StatelessWidget {
  /// Creates a floating tool window.
  const FloatingToolWindow({
    super.key,
    required this.tools,
    required this.selectedToolId,
    required this.onToolSelected,
    required this.onToolLongPress,
    required this.onExportPdf,
    required this.onBackPressed,
  });

  /// Available drawing tools.
  final List<DrawingTool> tools;

  /// ID of the currently selected tool.
  final String selectedToolId;

  /// Callback when a tool is selected (tool ID).
  final ValueChanged<String> onToolSelected;

  /// Callback when a tool is long-pressed for configuration.
  final ValueChanged<DrawingTool> onToolLongPress;

  /// Callback to export the note as PDF.
  final VoidCallback onExportPdf;

  /// Callback when the back button is pressed.
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Back Button
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Zurück zur Übersicht',
              onPressed: onBackPressed,
            ),
            
            const SizedBox(width: 8),
            Container(
              height: 24,
              width: 1,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(width: 8),

            // Tool Palette
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: DrawingToolPalette(
                tools: tools,
                selectedToolId: selectedToolId,
                onToolSelected: onToolSelected,
                onToolLongPress: onToolLongPress,
              ),
            ),

            const SizedBox(width: 8),
            Container(
              height: 24,
              width: 1,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(width: 8),

            // Export Button
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: 'Exportieren',
              onPressed: onExportPdf,
            ),
          ],
        ),
      ),
    );
  }
}
