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
    required this.onTogglePageOverview,
    required this.onBackPressed,
    this.orientation = Axis.horizontal,
  });

  /// Available drawing tools.
  final List<DrawingTool> tools;

  /// ID of the currently selected tool.
  final String selectedToolId;

  /// Callback when a tool is selected (tool ID).
  final ValueChanged<String> onToolSelected;

  /// Callback when a tool is long-pressed for configuration.
  final ValueChanged<DrawingTool> onToolLongPress;

  /// Callback when the page overview should be toggled.
  final VoidCallback onTogglePageOverview;

  /// Callback when the back button is pressed.
  final VoidCallback onBackPressed;

  /// The orientation of the toolbar.
  final Axis orientation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    DrawingTool? findToolById(String toolId) {
      for (final tool in tools) {
        if (tool.id == toolId) return tool;
      }
      return null;
    }

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      color: colorScheme.surface,
      child: Padding(
        padding: orientation == Axis.horizontal
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Flex(
          direction: orientation,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const IconButton(
              icon: Icon(Icons.drag_indicator_rounded),
              onPressed: null,
              tooltip: 'Verschieben',
            ),

            const SizedBox(width: 4, height: 4),

            // Back Button
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBackPressed,
              tooltip: 'Zurück',
            ),

            const SizedBox(width: 4, height: 4),
            _Divider(
              orientation: orientation,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(width: 4, height: 4),

            // Tool Palette
            DrawingToolPalette(
              tools: tools,
              selectedToolId: selectedToolId,
              direction: orientation,
              onToolSelected: onToolSelected,
              onToolEdit: onToolLongPress,
              onToolDelete: (toolId) {
                final tool = findToolById(toolId);
                if (tool == null) return;
                onToolLongPress(tool);
              },
            ),

            const SizedBox(width: 4, height: 4),
            _Divider(
              orientation: orientation,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(width: 4, height: 4),

            // Page Overview
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              onPressed: onTogglePageOverview,
              tooltip: 'Seitenübersicht',
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.orientation, required this.color});
  final Axis orientation;
  final Color color;

  @override
  Widget build(BuildContext context) => orientation == Axis.horizontal
      ? Container(height: 24, width: 1, color: color)
      : Container(height: 1, width: 24, color: color);
}
