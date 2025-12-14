import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/drawing_tool_palette.dart';
import 'package:flutter/material.dart';

/// AppBar for the drawing note page.
///
/// Contains the note title, page indicator, tool palette, and export action.
/// Extracted to isolate rebuilds from the main canvas area.
class DrawingNoteAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a drawing note app bar.
  const DrawingNoteAppBar({
    super.key,
    required this.title,
    required this.currentPageIndex,
    required this.totalPages,
    required this.tools,
    required this.selectedToolId,
    required this.onToolSelected,
    required this.onToolLongPress,
    required this.onExportPdf,
  });

  /// The note title to display.
  final String title;

  /// Current page index (0-based).
  final int currentPageIndex;

  /// Total number of pages.
  final int totalPages;

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

  @override
  Size get preferredSize => const Size.fromHeight(94);

  @override
  Widget build(BuildContext context) => AppBar(
        leading: const BackButton(),
        centerTitle: true,
        toolbarHeight: 94,
        titleSpacing: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Seite ${currentPageIndex + 1} / $totalPages',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: DrawingToolPalette(
                tools: tools,
                selectedToolId: selectedToolId,
                onToolSelected: (id) => onToolSelected(id),
                onToolLongPress: onToolLongPress,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Als PDF exportieren',
            onPressed: onExportPdf,
          ),
          const SizedBox(width: 8),
        ],
      );
}
