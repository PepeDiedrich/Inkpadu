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
    required this.onToolEdit,
    required this.onToolDelete,
    required this.onAddTool,
    required this.onExportPdf,
    required this.onBackPressed,
    this.orientation = Axis.horizontal,
  });

  /// Available drawing tools.
  final List<DrawingTool> tools;

  /// ID of the currently selected tool.
  final String selectedToolId;

  /// Callback when a tool is selected (tool ID).
  final ValueChanged<String> onToolSelected;

  /// Callback when a tool is to be edited.
  final ValueChanged<DrawingTool> onToolEdit;

  /// Callback when a tool is to be deleted.
  final ValueChanged<String> onToolDelete;

  /// Callback to add a new tool.
  final VoidCallback onAddTool;

  /// Callback to export the note as PDF.
  final VoidCallback onExportPdf;

  /// Callback when the back button is pressed.
  final VoidCallback onBackPressed;

  /// The orientation of the toolbar.
  final Axis orientation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isVertical = orientation == Axis.vertical;

    Widget divider() => isVertical
        ? Divider(
            height: 16,
            indent: 8,
            endIndent: 8,
            color: colorScheme.outlineVariant,
          )
        : Container(
            height: 24,
            width: 1,
            color: colorScheme.outlineVariant,
          );

    Widget gap() => SizedBox(
          width: isVertical ? 0 : 8,
          height: isVertical ? 8 : 0,
        );

    final Widget content = Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isVertical ? 8 : 12,
          vertical: isVertical ? 12 : 8,
        ),
        child: SingleChildScrollView(
          scrollDirection: orientation,
          child: Flex(
            direction: orientation,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Zurück zur Übersicht',
                onPressed: onBackPressed,
              ),

              gap(),
              divider(),
              gap(),

              // Tool Palette
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 40,
                  maxWidth: isVertical ? 70 : double.infinity,
                ),
                child: DrawingToolPalette(
                  tools: tools,
                  selectedToolId: selectedToolId,
                  onToolSelected: onToolSelected,
                  onToolEdit: onToolEdit,
                  onToolDelete: onToolDelete,
                  direction: orientation,
                ),
              ),

              // Add Button
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                tooltip: 'Neues Werkzeug',
                onPressed: onAddTool,
              ),

              gap(),
              divider(),
              gap(),

              // Export Button
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: 'Exportieren',
                onPressed: onExportPdf,
              ),
            ],
          ),
        ),
      ),
    );

    if (isVertical) {
      return SizedBox(
        width: 70,
        child: content,
      );
    }

    return content;
  }
}
