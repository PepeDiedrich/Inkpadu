import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:ai_handwriting_app/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// Zeigt die Werkzeugauswahl mit Schnellzugriff und Long-Press-Editor an.
class DrawingToolPalette extends StatelessWidget {
  /// Erstellt eine Palette mit den übergebenen Werkzeugen.
  const DrawingToolPalette({
    super.key,
    required this.tools,
    required this.selectedToolId,
    required this.onToolSelected,
    required this.onToolEdit,
    required this.onToolDelete,
    this.direction = Axis.horizontal,
  });

  /// Verfügbare Werkzeuge.
  final List<DrawingTool> tools;

  /// Aktuell ausgewählte Werkzeug-ID.
  final String selectedToolId;

  /// Wird beim Auswählen eines Werkzeugs ausgelöst.
  final ValueChanged<String> onToolSelected;

  /// Wird zum Bearbeiten eines Werkzeugs ausgelöst (Tap auf ausgewähltes Werkzeug).
  final ValueChanged<DrawingTool> onToolEdit;

  /// Wird zum Löschen eines Werkzeugs ausgelöst (Long-Press).
  final ValueChanged<String> onToolDelete;

  /// Die Ausrichtung der Palette.
  final Axis direction;

  @override
  Widget build(BuildContext context) => Wrap(
    direction: direction,
    spacing: 8,
    runSpacing: 8,
    alignment: WrapAlignment.center,
    children: tools
        .map(
          (tool) => _ToolChip(
            tool: tool,
            isSelected: tool.id == selectedToolId,
            onPressed: () {
              if (tool.id == selectedToolId) {
                onToolEdit(tool);
              } else {
                onToolSelected(tool.id);
              }
            },
            onLongPress: () => onToolDelete(tool.id),
          ),
        )
        .toList(growable: false),
  );
}

class _ToolChip extends StatefulWidget {
  const _ToolChip({
    required this.tool,
    required this.isSelected,
    required this.onPressed,
    required this.onLongPress,
  });

  final DrawingTool tool;
  final bool isSelected;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  @override
  State<_ToolChip> createState() => _ToolChipState();
}

class _ToolChipState extends State<_ToolChip> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color displayColor = _toolDisplayColor(widget.tool, colorScheme);
    final Color borderColor = _borderColor(colorScheme, displayColor);
    final Color iconColor = _toolForegroundColor(displayColor, colorScheme);

    final bool isSelected = widget.isSelected;
    final double targetScale = isSelected ? 1.08 : 1.0;

    // Use tool's display color for the background, never override with accent color.
    final Color chipBackground = displayColor;

    // Icon color should adjust to the tool's background color.
    final Color chipIconColor = widget.tool.isHighlighter
        ? iconColor.withValues(alpha: 0.8)
        : widget.tool.isEraser
        ? colorScheme.onSurfaceVariant
        : iconColor;

    final bool isLasso = widget.tool.id == DrawingToolDefaults.aiLassoId;
    final String tooltipMessage = isLasso
        ? context.t.drawing.lasso
        : '${widget.tool.label} · ${widget.tool.baseWidth.toStringAsFixed(1)} px';

    return Tooltip(
      message: tooltipMessage,
      child: GestureDetector(
        onTap: widget.onPressed,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: targetScale,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: chipBackground,
              border: Border.all(
                color: isSelected ? AppColors.primaryAccent : borderColor,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryAccent.withValues(alpha: 0.45),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(widget.tool.icon, size: 18, color: chipIconColor),
            ),
          ),
        ),
      ),
    );
  }

  Color _borderColor(ColorScheme colorScheme, Color displayColor) {
    if (widget.tool.isEraser || displayColor.a < 1) {
      return colorScheme.outline;
    }
    return Colors.transparent;
  }

  Color _toolDisplayColor(DrawingTool tool, ColorScheme scheme) {
    if (tool.isEraser) {
      return scheme.surfaceContainerHighest.withValues(alpha: 0.9);
    }
    if (tool.isHighlighter) {
      return tool.color.withValues(alpha: 0.45);
    }
    if (tool.color == Colors.white) {
      return tool.color.withValues(alpha: 0.9);
    }
    return tool.color;
  }

  Color _toolForegroundColor(Color background, ColorScheme scheme) {
    final Color opaque = background.a == 1
        ? background
        : background.withValues(alpha: 1);
    final brightness = ThemeData.estimateBrightnessForColor(opaque);
    return brightness == Brightness.dark ? Colors.white : scheme.onSurface;
  }
}
