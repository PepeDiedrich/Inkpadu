import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:flutter/material.dart';

/// Zeigt die Werkzeugauswahl mit Schnellzugriff und Long-Press-Editor an.
class DrawingToolPalette extends StatelessWidget {
  /// Erstellt eine Palette mit den übergebenen Werkzeugen.
  const DrawingToolPalette({
    super.key,
    required this.tools,
    required this.selectedToolId,
    required this.onToolSelected,
    required this.onToolLongPress,
  });

  /// Verfügbare Werkzeuge.
  final List<DrawingTool> tools;

  /// Aktuell ausgewählte Werkzeug-ID.
  final String selectedToolId;

  /// Wird beim Auswählen eines Werkzeugs ausgelöst.
  final ValueChanged<String> onToolSelected;

  /// Wird beim Long-Press auf ein Werkzeug ausgelöst.
  final ValueChanged<DrawingTool> onToolLongPress;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    alignment: WrapAlignment.center,
    children: tools
        .map(
          (tool) => _ToolChip(
            tool: tool,
            isSelected: tool.id == selectedToolId,
            onPressed: () => onToolSelected(tool.id),
            onLongPress: () => onToolLongPress(tool),
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
  bool _isLongPressActive = false;

  void _setLongPressActive(bool value) {
    if (_isLongPressActive == value) {
      return;
    }
    setState(() => _isLongPressActive = value);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color displayColor = _toolDisplayColor(widget.tool, colorScheme);
    final Color borderColor = _borderColor(colorScheme, displayColor);
    final Color iconColor = _toolForegroundColor(displayColor, colorScheme);

    final bool highlight = widget.isSelected || _isLongPressActive;

    return Tooltip(
      message:
          '${widget.tool.label} · ${widget.tool.baseWidth.toStringAsFixed(1)} px',
      child: GestureDetector(
        onTap: widget.onPressed,
        onLongPress: widget.onLongPress,
        onLongPressStart: (_) => _setLongPressActive(true),
        onLongPressEnd: (_) => _setLongPressActive(false),
        onLongPressCancel: () => _setLongPressActive(false),
        child: AnimatedScale(
          scale: highlight ? 1.12 : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: displayColor,
              border: Border.all(
                color: highlight ? AppColors.primaryAccent : borderColor,
                width: highlight ? 3 : 1,
              ),
              boxShadow: highlight
                  ? [
                      BoxShadow(
                        color: AppColors.primaryAccent.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                widget.tool.icon,
                size: 18,
                color: widget.tool.isHighlighter
                    ? iconColor.withValues(alpha: 0.8)
                    : widget.tool.isEraser
                    ? colorScheme.onSurfaceVariant
                    : iconColor,
              ),
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
